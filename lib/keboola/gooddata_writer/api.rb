module Keboola
  module GoodDataWriter

    class API
      QUEUE_ENDPOINT_URL  = 'https://syrup.keboola.com/queue/'
      WRITER_ENDPOINT_URL = 'https://syrup.keboola.com/gooddata-writer/'
      QUEUE_MOCK_ENDPOINT_URL  = 'https://private-anon-c1bf53b9c-syrupqueue.apiary-mock.com/queue/'
      WRITER_MOCK_ENDPOINT_URL = 'https://private-anon-df256c5fb-keboolagooddatawriter.apiary-mock.com/gooddata-writer/'

      attr_accessor :token, :client, :queue, :parser


      def initialize(token: nil, endpoint: nil, client: nil, queue: nil, parser: nil)
        @token  = token  || raise(ArgumentError, "token is required")
        @client = client || self.class.build_client(endpoint: endpoint || WRITER_ENDPOINT_URL, token: token)
        @queue  = queue  || self.class.build_client(endpoint: QUEUE_ENDPOINT_URL, token: token)
        @parser = parser || self.class.build_parser
      end

      def self.build_client(token: nil, endpoint: nil)
        Client.factory(token: token, endpoint: endpoint)
      end

      def self.build_parser
        Parser.new
      end


      # === Writer resource commands

      # Returns list of available writers and their buckets
      def writers
        handle(@client.get("writers")) { |result| result["writers"] }
      end

      # Returns attributes of the writer
      def writer(writer_id)
        handle(@client.get("writers", { writerId: writer_id })) { |result| result["writers"].first rescue result["writer"] }
      end

      # Creates new configuration bucket and either uses existing GoodData
      # project or creates new one along with dedicated GoodData user.
      def create_writer(writer_id, optionals: {}, async: true)
        params = { writerId: writer_id }.reverse_merge(optionals)
        handle(@client.post("writers", params.to_json)) { |result| job_handler(result, async) }
      end

      # Sets attributes to writer's configuration
      def update_writer(writer_id, attributes: {})
        handle(@client.post("writers/#{writer_id}", attributes.to_json)) { |result| job_handler(result).ok? }
      end

      # Deletes configuration bucket and enqueues GoodData project and dedicated GoodData user for removal
      def delete_writer(writer_id, async: true)
        handle(@client.delete("writers", { writerId: writer_id })) { |result| job_handler(result, async) }
      end


      # === Project resource commands

      # Returns list of project clones including main project marked with main: 1 field
      def projects(writer_id)
        handle(@client.get("projects", { writerId: writer_id })) { |result| result["projects"] }
      end

      # Creates new configuration bucket and either uses existing GoodData
      # project or creates new one along with dedicated GoodData user.
      def create_project(writer_id, optionals: {}, async: true)
        params = { writerId: writer_id }.reverse_merge(optionals)
        handle(@client.post("projects", params.to_json)) { |result| job_handler(result, async) }
      end

      # Creates new GoodData project for the writer and enqueues the old for deletion
      def reset_project(writer_id, optionals: {}, async: true)
        params = { writerId: writer_id }.reverse_merge(optionals)
        handle(@client.post("reset-project", params.to_json)) { |result| job_handler(result, async) }
      end

      # Upload project to GoodData
      def upload_project(writer_id, optionals: {}, async: true)
        params = { writerId: writer_id }.reverse_merge(optionals)
        handle(@client.post("upload-project", params.to_json)) { |result| job_handler(result, async) }
      end


      # === User resource commands

      # Get users list
      def users(writer_id)
        handle(@client.get("users", { writerId: writer_id })) { |result| result["users"] }
      end

      # Creates new GoodData user in Keboola domain.
      def create_user(writer_id, email, password, first_name, last_name, optionals: {}, async: true)
        params = { writerId: writer_id, email: email, password: password, firstName: first_name, lastName: last_name }.reverse_merge(optionals)
        handle(@client.post("users", params.to_json)) { |result| job_handler(result, async) }
      end


      # === Project & User nested resource commands

      # Get list of users in project
      def project_users(writer_id, project_id)
        handle(@client.get("project-users", { writerId: writer_id, pid: project_id })) { |result| result["users"] }
      end

      # Adds GoodData user to specified project.
      def add_project_users(writer_id, project_id, email, role, optionals: {}, async: true)
        params = { writerId: writer_id, pid: project_id, email: email, role: role }.reverse_merge(optionals)
        handle(@client.post("project-users", params.to_json)) { |result| job_handler(result, async) }
      end

      # Remove user from specified project.
      def remove_project_users(writer_id, project_id, email, async: true)
        params = { writerId: writer_id, pid: project_id, email: email }
        handle(@client.delete("project-users", params)) { |result| job_handler(result, async) }
      end


      # === GoodData project structure commands

      # Get tables list
      def tables(writer_id)
        handle(@client.get("tables", { writerId: writer_id })) { |result| result["tables"] }
      end

      # Get table detail
      def table(writer_id, table_id)
        handle(@client.get("tables", { writerId: writer_id, tableId: table_id })) { |result| result["tables"].first rescue result["table"] }
      end

      # Update table configuration
      def update_table(writer_id, table_id, optionals: {})
        params = { writerId: writer_id, tableId: table_id }.reverse_merge(optionals)
        handle(@client.post("tables", params.to_json)) { |result| job_handler(result).ok? }
      end

      # Update table column configuration
      def update_table_column(writer_id, table_id, column, optionals: {})
        params = { writerId: writer_id, tableId: table_id, column: column }.reverse_merge(optionals)
        handle(@client.post("tables", params.to_json)) { |result| job_handler(result).ok? }
      end

      # Bulk update table column configuration
      def bulk_update_table_column(writer_id, table_id, columns = [])
        params = { writerId: writer_id, tableId: table_id, columns: columns }
        handle(@client.post("tables", params.to_json)) { |result| job_handler(result).ok? }
      end

      # Upload selected table to GoodData
      def upload_table(writer_id, table_id, optionals: {}, async: true)
        params = { writerId: writer_id, tableId: table_id }.reverse_merge(optionals)
        handle(@client.post("upload-table", params.to_json)) { |result| job_handler(result, async) }
      end

      # Update model of selected table in GoodData
      def update_table_model(writer_id, optionals: {}, async: true)
        params = { writerId: writer_id }.reverse_merge(optionals)
        handle(@client.post("update-model", params.to_json)) { |result| job_handler(result, async) }
      end
      alias_method :update_model, :update_table_model

      # Remove dataset in GoodData project belonging to the table and reset it's export status
      def reset_table(writer_id, table_id, optionals: {}, async: true)
        params = { writerId: writer_id, tableId: table_id }.reverse_merge(optionals)
        handle(@client.post("reset-table", params.to_json)) { |result| job_handler(result, async) }
      end

      # Selectively upload date dimension (must be already configured in Writer)
      def upload_date_dimension(writer_id, name, optionals: {}, async: true)
        params = { writerId: writer_id, name: name }.reverse_merge(optionals)
        handle(@client.post("reset-table", params.to_json)) { |result| job_handler(result, async) }
      end


      # === Commands for loading data into GoodData

      # Load data to selected tables in GoodData
      def load_data(writer_id, optionals: {}, async: true)
        params = { writerId: writer_id }.reverse_merge(optionals)
        handle(@client.post("load-data", params.to_json)) { |result| job_handler(result, async) }
      end

      # Load data to selected tables in GoodData concurrently
      def load_data_multi(writer_id, optionals: {}, async: true)
        params = { writerId: writer_id }.reverse_merge(optionals)
        handle(@client.post("load-data-multi", params.to_json)) { |result| job_handler(result, async) }
      end

      # === Filter resource

      def filters(writer_id, optionals: {})
        params = { writerId: writer_id }.reverse_merge(optionals)
        handle(@client.get("filters", params)) { |result| result["filters"] }
      end

      def create_filter(writer_id, project_id, name, attribute, value, operator = '=', optionals: {}, async: true)
        params = { writerId: writer_id, pid: project_id, name: name, attribute: attribute, operator: operator, value: value }.reverse_merge(optionals)
        handle(@client.post("filters", params.to_json)) { |result| job_handler(result, async) }
      end

      def delete_filter(writer_id, name, async: true)
        handle(@client.delete("filters", { writerId: writer_id, name: name })) { |result| job_handler(result, async) }
      end


      # === Commands for manipulation with GoodData's Mandatory User Filters

      # Get Filters for Projects
      def filters_projects(writer_id, optionals: {})
        params = { writerId: writer_id }.reverse_merge(optionals)
        handle(@client.get("filters-projects", params)) { |result| result["filters"] }
      end

      # Get Filters for Users
      def filters_users(writer_id, optionals: {})
        params = { writerId: writer_id }.reverse_merge(optionals)
        handle(@client.get("filters-users", params)) { |result| result["filters"] }
      end

      # Assign Filter to User
      def assign_filters_users(writer_id, email, filters = [], optionals: {}, async: true)
        params = { writerId: writer_id, email: email, filters: filters }.reverse_merge(optionals)
        handle(@client.post("filters-users", params.to_json)) { |result| job_handler(result, async) }
      end

      # Synchronizes filters in GoodData project according to writer's configuration
      def sync_filters(writer_id, optionals: {}, async: true)
        params = { writerId: writer_id }.reverse_merge(optionals)
        handle(@client.post("sync-filters", params.to_json)) { |result| job_handler(result, async) }
      end


      # === Various GoodData commands

      # Execute selected reports in GoodData
      def execute_reports(writer_id, project_id, optionals: {}, async: true)
        params = { writerId: writer_id, pid: project_id }.reverse_merge(optionals)
        handle(@client.post("execute-reports", params.to_json)) { |result| job_handler(result, async) }
      end

      # Call to obtain an SSO link for user
      def sso(writer_id, project_id, email, optionals: {})
        params = { writerId: writer_id, pid: project_id, email: email }.reverse_merge(optionals)
        handle(@client.get("sso", params)) { |result| result["ssoLink"] }
      end

      # Simple proxy for direct calls to GoodData API
      def proxy(method, writer_id, query, optionals: {}, async: true)
        params = { writerId: writer_id, query: query }.reverse_merge(optionals)
        case method.to_sym
          when :get
            if block_given?
              handle(@client.get("proxy", params)) { |result| yield result }
            else
              handle(@client.get("proxy", params))
            end
          when :post
            handle(@client.post("proxy", params.to_json)) { |result| job_handler(result, async) }
        end
      end


      # === Commands for jobs handling in Syrup Queue API

      # Return list of jobs for given writer
      def jobs(writer_id)
        handle(@queue.get("jobs", { q: "+params.writerId:#{writer_id}", limit: 50 })) { |result| result.map { |hash| job_handler(hash) } }
      end

      # Return detail of given job
      def job(job_id)
        handle(@queue.get("jobs/#{job_id}")) { |result| job_handler(result) }
      end

      # Ask repeatedly for job status until it is finished
      def wait_for_job(job_id)
        begin
          job = job(job_id)
          sleep 5 unless job.finished?
        end until job.finished?

        raise JobError.new(job) if job.error?
        job
      end


      private

      def job_handler(result, async = true)
        async ? Job.new(result) : wait_for_job(result["id"])
      end

      # Properly handle response of API call request
      def handle(response, &handler)
        result = case response.status_type
          when :success # Is this a 2xx response?
            @parser.parse(response.body)

          when :redirection # Is this a 3xx redirect?
            @parser.parse(response.body)

          when :client_error # Is this is a 4xx response?
            raise ClientError.new(response)

          when :server_error # Is this a 5xx response?
            raise ServerError.new(response)

          else
            raise ResponseError.new(response)
        end

        handler.nil? ? result : handler.call(result)

      rescue ::Hurley::Error, ::Hurley::Timeout => e
        raise ResponseError.new(e)
      end
    end

  end
end
