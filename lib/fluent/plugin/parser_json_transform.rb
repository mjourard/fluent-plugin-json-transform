module Fluent
  class TextParser
    class JSONTransformParser
      DEFAULTS = [ 'nothing', 'flatten' ]
      DEFAULT_CLASS_NAME = 'JSONTransformer'

      include Configurable
      config_param :transform_script, :string
      config_param :script_path, :string
      config_param :class_name, :string

      def configure(conf)
        @transform_script = conf['transform_script']

        if DEFAULTS.include?(@transform_script)
          @transform_script = "#{__dir__}/../../transform/#{@transform_script}.rb"
          className = DEFAULT_CLASS_NAME
        elsif @transform_script == 'custom'
          @transform_script = conf['script_path']
          className = conf['class_name'] || DEFAULT_CLASS_NAME
        end

        require @transform_script
        begin
          @transformer = Object.const_get(className).new
        rescue NameError
          @transformer = Object.const_get(DEFAULT_CLASS_NAME).new
        end
      end

      def call(text)
        raw_json = JSON.parse(text)
        return nil, @transformer.transform(raw_json)
      end

      def parse(text)
        raw_json = JSON.parse(text)
        return nil, @transformer.transform(raw_json)
      end
    end
  register_template("json_transform", Proc.new { JSONTransformParser.new })
  end
end

