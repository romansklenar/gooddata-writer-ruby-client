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
        handle @client.get("writers") do |result|
          result["writers"]
        end
      end

      # Returns attributes of the writer
      def writer(writer_id)
        handle @client.get("writers", { writerId: writer_id }) do |result|
          result["writers"].first rescue result["writer"]
        end
      end

      # Creates new configuration bucket and either uses existing GoodData
      # project or creates new one along with dedicated GoodData user.
      def create_writer(writer_id, optionals: {}, async: true)
        handle @client.post("writers", { writerId: writer_id }.reverse_merge(optionals).to_json) do |result|
          job_handler(result, async)
        end
      end

      # Sets attributes to writer's configuration
      def update_writer(writer_id, attributes: {})
        handle @client.post("writers/#{writer_id}", attributes.to_json) do |result|
          job_handler(result).ok?
        end
      end

      # Deletes configuration bucket and enqueues GoodData project and dedicated GoodData user for removal
      def delete_writer(writer_id, async: true)
        handle @client.delete("writers", { writerId: writer_id }) do |result|
          job_handler(result, async)
        end
      end


      # === Project resource commands

      # Returns list of project clones including main project marked with main: 1 field
      def projects(writer_id)
        handle @client.get("projects", { writerId: writer_id }) do |result|
          result["projects"]
        end
      end

      # Creates new configuration bucket and either uses existing GoodData
      # project or creates new one along with dedicated GoodData user.
      def create_project(writer_id, optionals: {}, async: true)
        handle @client.post("projects", { writerId: writer_id }.reverse_merge(optionals).to_json) do |result|
          job_handler(result, async)
        end
      end

      # Creates new GoodData project for the writer and enqueues the old for deletion
      def reset_project(writer_id, optionals: {}, async: true)
        handle @client.post("reset-project", { writerId: writer_id }.reverse_merge(optionals).to_json) do |result|
          job_handler(result, async)
        end
      end

      # Upload project to GoodData
      def upload_project(writer_id, optionals: {}, async: true)
        handle @client.post("upload-project", { writerId: writer_id }.reverse_merge(optionals).to_json) do |result|
          job_handler(result, async)
        end
      end


      # === User resource commands

      # Get users list
      def users(writer_id)
        handle @client.get("users", { writerId: writer_id }) do |result|
          result["users"]
        end
      end

      # Creates new GoodData user in Keboola domain.
      def create_user(writer_id, email, password, first_name, last_name, optionals: {}, async: true)
        required = { writerId: writer_id, email: email, password: password, firstName: first_name, lastName: last_name }
        handle @client.post("users", required.reverse_merge(optionals).to_json) do |result|
          job_handler(result, async)
        end
      end


      # === Project & User nested resource commands

      # Get list of users in project
      def project_users(writer_id, project_id)
        handle @client.get("project-users", { writerId: writer_id, pid: project_id }) do |result|
          result["users"]
        end
      end

      # Adds GoodData user to specified project.
      def add_project_users(writer_id, project_id, email, role, optionals: {}, async: true)
        required = { writerId: writer_id, pid: project_id, email: email, role: role }
        handle @client.post("project-users", required.reverse_merge(optionals).to_json) do |result|
          job_handler(result, async)
        end
      end

      # Remove user from specified project.
      def remove_project_users(writer_id, project_id, email, async: true)
        handle @client.delete("project-users", { writerId: writer_id, pid: project_id, email: email }) do |result|
          job_handler(result, async)
        end
      end


      # === GoodData project structure commands

      # Get tables list
      def tables(writer_id)
        handle @client.get("tables", { writerId: writer_id }) do |result|
          result["tables"]
        end
      end

      # Get table detail
      def table(writer_id, table_id)
        handle @client.get("tables", { writerId: writer_id, tableId: table_id }) do |result|
          result["tables"].first rescue result["table"]
        end
      end

      # Update table configuration
      def update_table(writer_id, table_id, optionals: {})
        handle @client.post("tables", { writerId: writer_id, tableId: table_id }.reverse_merge(optionals).to_json) do |result|
          job_handler(result).ok?
        end
      end

      # Update table column configuration
      def update_table_column(writer_id, table_id, column, optionals: {})
        handle @client.post("tables", { writerId: writer_id, tableId: table_id, column: column }.reverse_merge(optionals).to_json) do |result|
          job_handler(result).ok?
        end
      end

      # Bulk update table column configuration
      def bulk_update_table_column(writer_id, table_id, columns = [])
        handle @client.post("tables", { writerId: writer_id, tableId: table_id, columns: columns }.to_json) do |result|
          job_handler(result).ok?
        end
      end

      # Upload selected table to GoodData
      def upload_table(writer_id, table_id, optionals: {}, async: true)
        handle @client.post("upload-table", { writerId: writer_id, tableId: table_id }.reverse_merge(optionals).to_json) do |result|
          job_handler(result, async)
        end
      end

      # Update model of selected table in GoodData
      def update_table_model(writer_id, optionals: {}, async: true)
        handle @client.post("update-model", { writerId: writer_id }.reverse_merge(optionals).to_json) do |result|
          job_handler(result, async)
        end
      end
      alias_method :update_model, :update_table_model

      # Remove dataset in GoodData project belonging to the table and reset it's export status
      def reset_table(writer_id, table_id, optionals: {}, async: true)
        handle @client.post("reset-table", { writerId: writer_id, tableId: table_id }.reverse_merge(optionals).to_json) do |result|
          job_handler(result, async)
        end
      end

      # Selectively upload date dimension (must be already configured in Writer)
      def upload_date_dimension(writer_id, name, optionals: {}, async: true)
        handle @client.post("reset-table", { writerId: writer_id, name: name }.reverse_merge(optionals).to_json) do |result|
          job_handler(result, async)
        end
      end


      # === Commands for loading data into GoodData

      # Load data to selected tables in GoodData
      def load_data(writer_id, optionals: {}, async: true)
        handle @client.post("load-data", { writerId: writer_id }.reverse_merge(optionals).to_json) do |result|
          job_handler(result, async)
        end
      end

      # Load data to selected tables in GoodData concurrently
      def load_data_multi(writer_id, optionals: {}, async: true)
        handle @client.post("load-data-multi", { writerId: writer_id }.reverse_merge(optionals).to_json) do |result|
          job_handler(result, async)
        end
      end

      # === Filter resource

      def filters(writer_id, optionals: {})
        handle @client.get("filters", { writerId: writer_id }.reverse_merge(optionals)) do |result|
          result["filters"]
        end
      end

      def create_filter(writer_id, project_id, name, attribute, value, operator = '=', optionals: {}, async: true)
        required = { writerId: writer_id, pid: project_id, name: name, attribute: attribute, operator: operator, value: value }
        handle @client.post("filters", required.reverse_merge(optionals).to_json) do |result|
          job_handler(result, async)
        end
      end

      def delete_filter(writer_id, name, async: true)
        handle @client.delete("filters", { writerId: writer_id, name: name }) do |result|
          job_handler(result, async)
        end
      end


      # === Commands for manipulation with GoodData's Mandatory User Filters

      # Get Filters for Projects
      def filters_projects(writer_id, optionals: {})
        handle @client.get("filters-projects", { writerId: writer_id }.reverse_merge(optionals)) do |result|
          result["filters"]
        end
      end

      # Get Filters for Users
      def filters_users(writer_id, optionals: {})
        handle @client.get("filters-users", { writerId: writer_id }.reverse_merge(optionals)) do |result|
          result["filters"]
        end
      end

      # Assign Filter to User
      def assign_filters_users(writer_id, email, filters = [], optionals: {}, async: true)
        required = { writerId: writer_id, email: email, filters: filters }
        handle @client.post("filters-users", required.reverse_merge(optionals).to_json) do |result|
          job_handler(result, async)
        end
      end

      # Synchronizes filters in GoodData project according to writer's configuration
      def sync_filters(writer_id, optionals: {}, async: true)
        handle @client.post("sync-filters", { writerId: writer_id }.reverse_merge(optionals).to_json) do |result|
          job_handler(result, async)
        end
      end


      # === Various GoodData commands

      # Execute selected reports in GoodData
      def execute_reports(writer_id, project_id, optionals: {}, async: true)
        handle @client.post("execute-reports", { writerId: writer_id, pid: project_id }.reverse_merge(optionals).to_json) do |result|
          job_handler(result, async)
        end
      end

      # Call to obtain an SSO link for user
      def sso(writer_id, project_id, email, optionals: {})
        handle @client.get("sso", { writerId: writer_id, pid: project_id, email: email }.reverse_merge(optionals)) do |result|
          result["ssoLink"]
        end
      end

      # Simple proxy for direct calls to GoodData API
      def proxy(method, writer_id, query, optionals: {}, async: true)
        required = { writerId: writer_id, query: query }
        case method.to_sym
          when :get
            handle @client.get("proxy", required.reverse_merge(optionals))
          when :post
            handle @client.post("proxy", required.reverse_merge(optionals).to_json) do |result|
              job_handler(result, async)
            end
        end
      end


      # === Commands for jobs handling in Syrup Queue API

      # Return list of jobs for given writer
      def jobs(writer_id)
        handle @queue.get("jobs", { q: "+params.writerId:#{writer_id}", limit: 50 }) do |result|
          result.map { |hash| job_handler(hash) }
        end
      end

      # Return detail of given job
      def job(job_id)
        handle @queue.get("jobs/#{job_id}") do |result|
          job_handler(result)
        end
      end

      # Ask repeatedly for job status until it is finished
      def wait_for_job(job_id)
        begin
          job = job(job_id)
          sleep 5 unless job.finished?
        end until job.finished?
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
