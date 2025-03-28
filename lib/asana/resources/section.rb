require_relative 'gen/sections_base'

module Asana
  module Resources
    # A _section_ is a subdivision of a project that groups tasks together. It can
    # either be a header above a list of tasks in a list view or a column in a
    # board view of a project.
    class Section < SectionsBase


      attr_reader :gid

      attr_reader :resource_type

      attr_reader :name

      attr_reader :project

      attr_reader :created_at

      class << self
        # Returns the plural name of the resource.
        def plural_name
          'sections'
        end

        # Creates a new section in a project.
        #
        # Returns the full record of the newly created section.
        #
        # project - [Gid] The project to create the section in
        # name - [String] The text to be displayed as the section name. This cannot be an empty string.
        # options - [Hash] the request I/O options.
        # data - [Hash] the attributes to post.
        def create_in_project(client, project: required("project"), name: required("name"), options: {}, **data)
          with_params = data.merge(name: name).reject { |_,v| v.nil? || Array(v).empty? }
          self.new(parse(client.post("/projects/#{project}/sections", body: with_params, options: options)).first, client: client)
        end

        # Returns the compact records for all sections in the specified project.
        #
        # project - [Gid] The project to get sections from.
        # per_page - [Integer] the number of records to fetch per page.
        # options - [Hash] the request I/O options.
        def find_by_project(client, project: required("project"), per_page: 20, options: {})
          params = { limit: per_page }.reject { |_,v| v.nil? || Array(v).empty? }
          Collection.new(parse(client.get("/projects/#{project}/sections", params: params, options: options)), type: self, client: client)
        end

        # Returns the complete record for a single section.
        #
        # id - [Gid] The section to get.
        # options - [Hash] the request I/O options.
        def find_by_id(client, id, options: {})

          self.new(parse(client.get("/sections/#{id}", options: options)).first, client: client)
        end
      end

      # A specific, existing section can be updated by making a PUT request on
      # the URL for that project. Only the fields provided in the `data` block
      # will be updated; any unspecified fields will remain unchanged. (note that
      # at this time, the only field that can be updated is the `name` field.)
      #
      # When using this method, it is best to specify only those fields you wish
      # to change, or else you may overwrite changes made by another user since
      # you last retrieved the task.
      #
      # Returns the complete updated section record.
      #
      # options - [Hash] the request I/O options.
      # data - [Hash] the attributes to post.
      def update(options: {}, **data)

        refresh_with(parse(client.put("/sections/#{gid}", body: data, options: options)).first)
      end

      # A specific, existing section can be deleted by making a DELETE request
      # on the URL for that section.
      #
      # Note that sections must be empty to be deleted.
      #
      # The last remaining section in a board view cannot be deleted.
      #
      # Returns an empty data block.
      def delete()

        client.delete("/sections/#{gid}") && true
      end

      # Add a task to a specific, existing section. This will remove the task from other sections of the project.
      #
      # The task will be inserted at the top of a section unless an `insert_before` or `insert_after` parameter is declared.
      #
      # This does not work for separators (tasks with the `resource_subtype` of section).
      #
      # insert_before - [Gid] Insert the given task immediately before the task specified by this parameter. Cannot be provided together with `insert_after`.
      # insert_after - [Gid] Insert the given task immediately after the task specified by this parameter. Cannot be provided together with `insert_before`.
      # options - [Hash] the request I/O options.
      # data - [Hash] the attributes to post.
      def add_task(insert_before: nil, insert_after: nil, options: {}, **data)
        with_params = data.merge(insert_before: insert_before, insert_after: insert_after).reject { |_,v| v.nil? || Array(v).empty? }
        Task.new(parse(client.post("/sections/#{gid}/addTask", body: with_params, options: options)).first, client: client)
      end

      # Move sections relative to each other in a board view. One of
      # `before_section` or `after_section` is required.
      #
      # Sections cannot be moved between projects.
      #
      # At this point in time, moving sections is not supported in list views, only board views.
      #
      # Returns an empty data block.
      #
      # project - [Gid] The project in which to reorder the given section
      # before_section - [Gid] Insert the given section immediately before the section specified by this parameter.
      # after_section - [Gid] Insert the given section immediately after the section specified by this parameter.
      # options - [Hash] the request I/O options.
      # data - [Hash] the attributes to post.
      def insert_in_project(project: required("project"), before_section: nil, after_section: nil, options: {}, **data)
        with_params = data.merge(before_section: before_section, after_section: after_section).reject { |_,v| v.nil? || Array(v).empty? }
        client.post("/projects/#{project}/sections/insert", body: with_params, options: options) && true
      end

    end
  end
end
