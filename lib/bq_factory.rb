require "active_support"
require "active_support/core_ext"
require "bq_factory/version"
require "bq_factory/attribute"
require "bq_factory/record"
require "bq_factory/client"
require "bq_factory/configuration"
require "bq_factory/dsl"
require "bq_factory/errors"
require "bq_factory/proxy"
require "bq_factory/query_builder"
require "bq_factory/record"
require "bq_factory/registory"
require "bq_factory/registory_decorator"

module BqFactory
  class << self
    delegate :fetch_schema_from_bigquery, :create_dataset!, :delete_dataset!, :create_table!, :delete_table!, :query,
             :register, :schema_by_name, :configuration, :project_id, :keyfile_path, :client, to: :proxy

    def configure
      yield configuration if block_given?
      configuration
    end

    def define(&block)
      DSL.run(block)
    end

    def create_view(dataset_name, factory_name, rows)
      query = build_query(factory_name, rows)
      client.create_view(dataset_name, factory_name, query)
    end

    def build_query(factory_name, rows)
      schema = schema_by_name(factory_name)
      QueryBuilder.new(schema).build(rows)
    end

    private

    def proxy
      @facade ||= Proxy.new
    end
  end
end
