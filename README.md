# JSON Transform parser plugin for Fluentd

##Overview
This is a [parser plugin](http://docs.fluentd.org/articles/parser-plugin-overview) for fluentd. It is **INCOMPATIBLE WITH FLUENTD v0.10.45 AND BELOW.**


It was created for the purpose of modifying [**good.js**](https://github.com/hapijs/good) logs
before storing them in Elasticsearch. It may not be useful for any other purpose, but be creative.

##Installation
```bash
gem install fluent-plugin-json-transform
```

##Configuration
```
<source>
  type [tail|tcp|udp|syslog|http] # or a custom input type which accepts the "format" parameter
  format json_transform
  transform_script [nothing|flatten|custom]
  script_path "/home/grayson/transform_script.rb" # ignored if transform_script != custom
</source>
```

`transform_script`: `nothing` to do nothing, `flatten` to flatten JSON by concatenating nested keys (see below), or `custom` 

`script_path`: ignored if not using `custom` script. Point this to a Ruby script which implements the `JSONTransformer` class.

###Flatten script
Flattens nested JSON by concatenating nested keys with '.'. Example:

```
{
  "hello": {
    "world": true
  },
  "goodbye": {
    "for": {
      "now": true,
      "ever": false
    }
  }
}
```

Becomes

```
{
  "hello.world": true,
  "goodbye.for.now": true,
  "goodbye.for.ever": false
}
```

###New Filter Option
Filtering is now supported, if you want to flatten your json after doing other parsing from the original source log.
```
<filter pattern>
  @type json_transform
  transform_script [nothing|flatten|custom]
  script_path "/home/grayson/transform_script.rb" # ignored if transform_script != custom
</filter>
```


##Implementing JSONTransformer

The `JSONTransformer` class should have an instance method `transform` which takes a Ruby hash and returns a Ruby hash:

```ruby
# lib/transform/flatten.rb
class JSONTransformer
  def transform(json)
    return flatten(json, "")
  end

  def flatten(json, prefix)
    json.keys.each do |key|
      if prefix.empty?
        full_path = key
      else
        full_path = [prefix, key].join('.')
      end

      if json[key].is_a?(Hash)
        value = json[key]
        json.delete key
        json.merge! flatten(value, full_path)
      else
        value = json[key]
        json.delete key
        json[full_path] = value
      end
    end
    return json
  end
end
```
