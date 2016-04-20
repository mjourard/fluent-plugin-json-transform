module Fluent
  class JSONTransformFilter < Filter
    Fluent::Plugin.register_filter('json_transform', self)

    DEFAULTS = [ 'nothing', 'flatten' ]

    include Configurable
    config_param :transform_script, :string
    config_param :script_path, :string

    def configure(conf)
      @transform_script = conf['transform_script']

      if DEFAULTS.include?(@transform_script)
        @transform_script = "#{__dir__}/../../transform/#{@transform_script}.rb"
      elsif @transform_script == 'custom'
        @transform_script = conf['script_path']
      end

      require @transform_script
      @transformer = JSONTransformer.new
    end

    def filter(tag, time, record)
      flattened = @transformer.transform(record)
      return flattened
    end
  end
end