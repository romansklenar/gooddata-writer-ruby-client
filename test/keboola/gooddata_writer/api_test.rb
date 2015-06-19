require 'test_helper'

class Keboola::GoodDataWriter::ApiTest < Minitest::Test
  def setup
    token = '123-abcdefghjklmnopqrstuvxyz' # KEBOOLA_STORAGE_API_TOKEN
    @api = Keboola::GoodDataWriter::API.new(token: token)

    # run tests on mock servers (if you don't want to test on mock servers then comment following 2 lines)
    @api.client = Keboola::GoodDataWriter::API.build_client(token: token, endpoint: Keboola::GoodDataWriter::API::WRITER_MOCK_ENDPOINT_URL)
    @api.queue  = Keboola::GoodDataWriter::API.build_client(token: token, endpoint: Keboola::GoodDataWriter::API::QUEUE_MOCK_ENDPOINT_URL)
  end

  def teardown
    VCR.eject_cassette
  end


  # === Writer resource commands tests

  def test_it_can_get_details_of_available_writers
    VCR.insert_cassette 'writers'
    writers = @api.writers

    assert_kind_of Array, writers
    assert_equal 2, writers.size

    assert_kind_of Hash, writers.first
    assert_kind_of Hash, writers.last

    assert_equal "sys.c-wr-gooddata-writer1", writers.first["bucket"]
    assert_equal "sys.c-wr-gooddata-writer2", writers.last["bucket"]
  end

  def test_it_can_get_details_of_specific_writer
    VCR.insert_cassette 'writer'
    writer = @api.writer('writer1')

    assert_kind_of Hash, writer
    assert_equal "sys.c-wr-gooddata-writer1", writer["bucket"]
  end

  def test_it_can_create_writer
    VCR.insert_cassette 'create_writer'
    job = @api.create_writer('writer1', optionals: { description: 'Testing GoodData Writer', users: 'user1@clients.keboola.com,user2@clients.keboola.com' }, async: true)
    assert_job_info job
  end

  def test_it_can_create_writer_synchronously
    VCR.insert_cassette 'create_writer_synchronously'
    job = @api.create_writer('writer1', optionals: { description: 'Testing GoodData Writer', users: 'user1@clients.keboola.com,user2@clients.keboola.com' }, async: false)
    assert_job job
  end

  def test_it_can_update_writer
    VCR.insert_cassette 'update_writer'
    success = @api.update_writer('writer1', attributes: { description: 'Testing GoodData Writer' })
    assert success
  end

  def test_it_can_delete_writer
    VCR.insert_cassette 'delete_writer'
    job = @api.delete_writer('writer1', async: true)
    assert_job_info job
  end

  def test_it_can_delete_writer_synchronously
    VCR.insert_cassette 'delete_writer_synchronously'
    job = @api.delete_writer('writer1', async: false)
    assert_job job
  end


  # === Project resource commands tests

  def test_it_can_get_list_of_projects
    VCR.insert_cassette 'projects'
    projects = @api.projects('writer1')

    assert_kind_of Array, projects
    assert_equal 3, projects.size

    assert_kind_of Hash, projects.first
    assert_kind_of Hash, projects.last

    assert_equal "xjywplmhejceb6j3ezzlxiganmjavqio", projects.last["pid"]
    assert_equal "l7eqkx6daomtv5iw2912p019anskzt1n", projects.first["pid"]
    assert_equal 1, projects.first["active"]
    assert_equal 1, projects.first["main"]
  end

  def test_it_can_create_project
    VCR.insert_cassette 'create_project'
    job = @api.create_project('writer1', optionals: { name: 'KBC - project1 - writer1' }, async: true)
    assert_job_info job
  end

  def test_it_can_create_project_synchronously
    VCR.insert_cassette 'create_project_synchronously'
    job = @api.create_project('writer1', optionals: { name: 'KBC - project1 - writer1' }, async: false)
    assert_job job
  end

  def test_it_can_reset_project
    VCR.insert_cassette 'reset_project'
    job = @api.reset_project('writer1', optionals: { removeClones: true }, async: true)
    assert_job_info job
  end

  def test_it_can_reset_project_synchronously
    VCR.insert_cassette 'reset_project_synchronously'
    job = @api.reset_project('writer1', optionals: { removeClones: true }, async: false)
    assert_job job
  end

  def test_it_can_upload_project
    VCR.insert_cassette 'upload_project'
    job = @api.upload_project('writer1', optionals: { queue: 'secondary' }, async: true)
    assert_job_info job
  end

  def test_it_can_upload_project_synchronously
    VCR.insert_cassette 'upload_project_synchronously'
    job = @api.upload_project('writer1', optionals: { queue: 'secondary' }, async: false)
    assert_job job
  end


  # === User resource commands tests

  def test_it_can_get_list_of_users
    VCR.insert_cassette 'users'
    users = @api.users('writer1')

    assert_kind_of Array, users
    assert_equal 2, users.size

    assert_kind_of Hash, users.first
    assert_kind_of Hash, users.last

    assert_equal "user1@clients.keboola.com", users.first["email"]
    assert_equal "user2@clients.keboola.com", users.last["email"]
  end

  def test_it_can_create_user
    VCR.insert_cassette 'create_user'
    job = @api.create_user('writer1', 'user3@clients.keboola.com', 't0pS3cr3t', 'John', 'Doe', optionals: { queue: 'secondary' }, async: true)
    assert_job_info job
  end

  def test_it_can_create_user_synchronously
    VCR.insert_cassette 'create_user_synchronously'
    job = @api.create_user('writer1', 'user4@clients.keboola.com', 'W1nt3rIsC0m1ng', 'John', 'Snow', optionals: { queue: 'secondary' }, async: true)
    assert_job_info job
  end


  # === Project & User nested resource commands tests

  def test_it_can_get_list_of_project_users
    VCR.insert_cassette 'project_users'
    users = @api.project_users('writer1', 'project1')

    assert_kind_of Array, users
    assert_equal 2, users.size

    assert_kind_of Hash, users.first
    assert_kind_of Hash, users.last

    assert_equal "user1@clients.keboola.com", users.first["email"]
    assert_equal "user2@clients.keboola.com", users.last["email"]
    assert_equal "editor", users.first["role"]
    assert_equal "editor", users.last["role"]
  end

  def test_it_can_add_project_users
    VCR.insert_cassette 'add_project_users'
    job = @api.add_project_users('writer1', 'project1', 'user5@clients.keboola.com', 'admin', optionals: { queue: 'secondary' }, async: true)
    assert_job_info job
  end

  def test_it_can_add_project_users_synchronously
    VCR.insert_cassette 'add_project_users_synchronously'
    job = @api.add_project_users('writer1', 'project1', 'user6@clients.keboola.com', 'admin', optionals: { queue: 'secondary' }, async: false)
    assert_job job
  end

  def test_it_can_remove_project_users
    VCR.insert_cassette 'remove_project_users'
    job = @api.remove_project_users('writer1', 'qts6zrafhywwj4aafgt48jfwbm4zi5r7', 'user5@clients.keboola.com', async: true)
    assert_job_info job
  end

  def test_it_can_remove_project_users_synchronously
    VCR.insert_cassette 'remove_project_users_synchronously'
    job = @api.remove_project_users('writer1', 'qts6zrafhywwj4aafgt48jfwbm4zi5r7', 'user6@clients.keboola.com', async: false)
    assert_job job
  end


  # === GoodData project structure commands tests

  def test_it_can_get_list_of_tables
    VCR.insert_cassette 'tables'
    tables = @api.tables('writer1')

    assert_kind_of Array, tables
    assert_equal 2, tables.size

    assert_kind_of Hash, tables.first
    assert_kind_of Hash, tables.last

    assert_equal "out.c-main.categories", tables.first["id"]
    assert_equal "out.c-main.products", tables.last["id"]
    assert_equal "Categories", tables.first["name"]
    assert_equal "Products", tables.last["name"]
  end

  def test_it_can_get_details_of_specific_table
    VCR.insert_cassette 'table'
    table = @api.table('writer1', 'out.c-main.categories')

    assert_kind_of Hash, table
    assert_equal "out.c-main.categories", table["id"]
    assert_equal "Categories", table["name"]
  end

  def test_it_can_update_table
    VCR.insert_cassette 'update_table'
    success = @api.update_table('writer1', 'out.c-main.categories', optionals: { export: 0 })
    assert success
  end

  def test_it_can_update_table_column
    VCR.insert_cassette 'update_table_column'
    success = @api.update_table_column('writer1', 'out.c-main.categories', 'name', optionals: { type: 'varchar' })
    assert success
  end

  def test_it_can_bulk_update_table_column
    VCR.insert_cassette 'bulk_update_table_column'
    success = @api.bulk_update_table_column('writer1', 'out.c-main.categories', ['id', 'name'])
    assert success
  end

  def test_it_can_upload_table
    VCR.insert_cassette 'upload_table'
    job = @api.upload_table('writer1', 'out.c-main-products', optionals: { queue: 'secondary' }, async: true)
    assert_job_info job
  end

  def test_it_can_upload_table_synchronously
    VCR.insert_cassette 'upload_table_synchronously'
    job = @api.upload_table('writer1', 'out.c-main-products', optionals: { queue: 'secondary' }, async: false)
    assert_job job
  end

  def test_it_can_update_table_model
    VCR.insert_cassette 'update_table_model'
    job = @api.update_table_model('writer1', optionals: { pid: 'project1' }, async: true)
    assert_job_info job
  end

  def test_it_can_update_table_model_synchronously
    VCR.insert_cassette 'update_table_model_synchronously'
    job = @api.update_table_model('writer1', optionals: { pid: 'project1' }, async: false)
    assert_job job
  end

  def test_it_can_reset_table
    VCR.insert_cassette 'reset_table'
    job = @api.reset_table('writer1', 'out.c-main.table', optionals: { queue: 'secondary' }, async: true)
    assert_job_info job
  end

  def test_it_can_reset_table_synchronously
    VCR.insert_cassette 'reset_table_synchronously'
    job = @api.reset_table('writer1', 'out.c-main.table', optionals: { queue: 'secondary' }, async: false)
    assert_job job
  end

  def test_it_can_upload_date_dimension
    VCR.insert_cassette 'upload_date_dimension'
    job = @api.upload_date_dimension('writer1', 'ProductDate', optionals: { queue: 'secondary' }, async: true)
    assert_job_info job
  end

  def test_it_can_upload_date_dimension_synchronously
    VCR.insert_cassette 'upload_date_dimension_synchronously'
    job = @api.upload_date_dimension('writer1', 'ProductDate', optionals: { queue: 'secondary' }, async: false)
    assert_job job
  end


  # === Commands for loading data into GoodData tests

  def test_it_can_load_data
    VCR.insert_cassette 'load_data'
    job = @api.load_data('writer1', optionals: { tables: ["out.c-main.products", "out.c-main.categories"], queue: 'secondary' }, async: true)
    assert_job_info job
  end

  def test_it_can_load_data_synchronously
    VCR.insert_cassette 'load_data_synchronously'
    job = @api.load_data('writer1', optionals: { tables: ["out.c-main.products", "out.c-main.categories"], queue: 'secondary' }, async: false)
    assert_job job
  end

  def test_it_can_load_data_multi
    VCR.insert_cassette 'load_data_multi'
    job = @api.load_data_multi('writer1', optionals: { tables: ["out.c-main.products", "out.c-main.categories"], queue: 'secondary' }, async: true)
    assert_job_info job
  end

  def test_it_can_load_data_multi_synchronously
    VCR.insert_cassette 'load_data_multi_synchronously'
    job = @api.load_data_multi('writer1', optionals: { tables: ["out.c-main.products", "out.c-main.categories"], queue: 'secondary' }, async: false)
    assert_job job
  end


  # === Filter resource commands tests

  def test_it_can_get_list_of_filters
    VCR.insert_cassette 'filters'
    filters = @api.filters('writer1').reverse

    assert_kind_of Array, filters
    assert_equal 2, filters.size

    assert_kind_of Hash, filters.first
    assert_kind_of Hash, filters.last

    assert_equal "filter1", filters.first["name"]
    assert_equal "filter2", filters.last["name"]
    assert_equal "out.c-main.users.name", filters.first["attribute"]
    assert_equal "out.c-main.users.name", filters.last["attribute"]
    assert_equal "=", filters.first["operator"]
    assert_equal "<>", filters.last["operator"]
  end

  def test_it_can_create_filter
    VCR.insert_cassette 'create_filter'
    job = @api.create_filter('writer1', 'project1', 'filter1', 'out.c-main.users.name', 'john', '=', optionals: { queue: 'secondary' }, async: true)
    assert_job_info job
  end

  def test_it_can_create_filter_synchronously
    VCR.insert_cassette 'create_filter_synchronously'
    job = @api.create_filter('writer1', 'project1', 'filter1', 'out.c-main.users.name', 'john', '=', optionals: { queue: 'secondary' }, async: false)
    assert_job job
  end

  def test_it_can_delete_filter
    VCR.insert_cassette 'delete_filter'
    job = @api.delete_filter('writer1', 'filter1', async: true)
    assert_job_info job
  end

  def test_it_can_delete_filter_synchronously
    VCR.insert_cassette 'delete_filter_synchronously'
    job = @api.delete_filter('writer1', 'filter1', async: false)
    assert_job job
  end


  # === Commands for manipulation with GoodData's Mandatory User Filters tests

  def test_it_can_get_list_of_filters_projects
    VCR.insert_cassette 'filters_projects'
    filters = @api.filters_projects('writer1', optionals: { filter: 'filter1' })

    assert_kind_of Array, filters
    assert_equal 1, filters.size

    assert_kind_of Hash, filters.first

    assert_equal "filter1", filters.first["filter"]
    assert_equal "/gdc/md/PID/obj/123", filters.first["uri"]
    assert_equal "PID", filters.first["pid"]
  end

  def test_it_can_get_list_of_filters_users
    VCR.insert_cassette 'filters_users'
    filters = @api.filters_users('writer1', optionals: { filter: 'filter1' })

    assert_kind_of Array, filters
    assert_equal 1, filters.size

    assert_kind_of Hash, filters.first

    assert_equal "filter1", filters.first["filter"]
    assert_equal "user@domain.com", filters.first["email"]
    assert_equal "idopsfiui78ufdisfo", filters.first["id"]
  end

  def test_it_can_assign_filters_users
    VCR.insert_cassette 'assign_filters_users'
    job = @api.assign_filters_users('writer1', 'user@domain.com', ['filter1', 'filter2'], async: true)
    assert_job_info job
  end

  def test_it_can_assign_filters_users_synchronously
    VCR.insert_cassette 'assign_filters_users_synchronously'
    job = @api.assign_filters_users('writer1', 'user@domain.com', ['filter1', 'filter2'], async: false)
    assert_job job
  end

  def test_it_can_sync_filters
    VCR.insert_cassette 'sync_filters'
    job = @api.sync_filters('writer1', optionals: { queue: 'secondary' }, async: true)
    assert_job_info job
  end

  def test_it_can_sync_filters_synchronously
    VCR.insert_cassette 'sync_filters_synchronously'
    job = @api.sync_filters('writer1', optionals: { queue: 'secondary' }, async: false)
    assert_job job
  end


  # === Various GoodData commands tests

  def test_it_can_execute_reports
    VCR.insert_cassette 'execute_reports'
    job = @api.execute_reports('writer1', 'pr0j3ct_p1d', async: true)
    assert_job_info job
  end

  def test_it_can_execute_reports_synchronously
    VCR.insert_cassette 'execute_reports_synchronously'
    job = @api.execute_reports('writer1', 'pr0j3ct_p1d', async: false)
    assert_job job
  end

  def test_it_can_do_sso
    VCR.insert_cassette 'sso'
    url = @api.sso('writer1', 'pr0j3ct_p1d', 'user1@clients.keboola.com')
    assert_equal "https://secure.gooddata.com/gdc/account/customerlogin?sessionId=-----BEGIN+PGP+MESSAGE-----s0m3_l0000n6_h4sh", url
  end

  def test_it_can_do_proxy_get_call
    VCR.insert_cassette 'proxy_get'
    result = @api.proxy(:get, 'writer1', 'query')
    assert_kind_of Hash, result
    assert result.has_key?("response")
    assert_kind_of Hash, result["response"]
    assert result["response"].has_key?("foo")
    assert "bar", result["response"]["foo"]
  end

  def test_it_can_do_proxy_post_call
    VCR.insert_cassette 'proxy_post'
    job = @api.proxy(:post, 'writer1', 'query', async: true)
    assert_job_info job
  end

  def test_it_can_do_proxy_call_synchronously
    VCR.insert_cassette 'proxy_post_synchronously'
    job = @api.proxy(:post, 'writer1', 'query', async: false)
    assert_job job
  end


  # === Commands for jobs handling tests

  def test_it_can_get_list_of_queued_jobs
    VCR.insert_cassette 'jobs'
    jobs = @api.jobs('writerId')

    assert_kind_of Array, jobs
    assert_equal 1, jobs.size

    assert_kind_of Keboola::GoodDataWriter::Job, jobs.first
    assert_job jobs.first
  end

  def test_it_can_get_details_of_specific_job
    VCR.insert_cassette 'job'
    job = @api.job(123456)

    assert_job job
  end


  private

    def assert_job(job)
      assert_kind_of Keboola::GoodDataWriter::Job, job
      assert_respond_to job, :success?
      assert_respond_to job, :finished?
      refute_respond_to job, :url

      assert_equal true, job.success?
      assert_equal true, job.finished?
      assert_equal 123456, job.id
      assert_equal "success", job.status
      assert_equal "someComponent", job.component
    end

    def assert_job_info(job)
      assert_kind_of Keboola::GoodDataWriter::Job, job
      assert_respond_to job, :success?
      assert_respond_to job, :finished?
      assert_respond_to job, :url

      assert_equal false, job.success?
      assert_equal false, job.finished?
      assert_equal 'job_id', job.id
    end
end
