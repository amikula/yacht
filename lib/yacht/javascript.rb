require 'json'

class Yacht::Loader
  class << self
    def to_js_string(opts={})
      hash = to_hash(opts).slice(*js_keys)
      ";var Yacht = #{hash.to_json};"
    end

    def js_keys
      load_config_file(:js_keys, :expect_to_load => Array) || raise( Yacht::LoadError.new("Couldn't load js_keys") )
    end

    def to_js_file(opts={})
      # by default, set :dir to 'public/javascripts' in Rails
      opts[:dir] ||= Rails.root.join('public', 'javascripts').to_s if Object.const_defined?(:Rails)

      raise Yacht::LoadError.new("Must provide :dir option") if opts[:dir].nil?

      write_file(opts[:dir], 'Yacht.js', js_comment << to_js_string(opts))
    end

    def write_file(dir, name, contents)
      FileUtils.mkdir_p dir

      File.open File.join(dir, name), 'w' do |file|
        file.write(contents)
      end
    end

    private
      def js_comment
          ";\n" +
          '// _______________________________________          ' + "\n" +
          '// / DO NOT EDIT THIS FILE DIRECTLY. Yacht \        ' + "\n" +
          '// \ generated this file from js_keys.yml  /        ' + "\n" +
          '// ---------------------------------------          ' + "\n" +
          '//         \                                        ' + "\n" +
          '//          \                                       ' + "\n" +
          '//           \          __---__                     ' + "\n" +
          '//                   _-       /--______             ' + "\n" +
          '//              __--( /     \ )XXXXXXXXXXX\v.       ' + "\n" +
          '//            .-XXX(   O   O  )XXXXXXXXXXXXXXX-     ' + "\n" +
          '//           /XXX(       U     )        XXXXXXX\    ' + "\n" +
          '//         /XXXXX(              )--_  XXXXXXXXXXX\  ' + "\n" +
          '//        /XXXXX/ (      O     )   XXXXXX   \XXXXX\ ' + "\n" +
          '//        XXXXX/   /            XXXXXX   \__ \XXXXX ' + "\n" +
          '//        XXXXXX__/          XXXXXX         \__---->' + "\n" +
          '// ---___  XXX__/          XXXXXX      \__         /' + "\n" +
          '//  \-  --__/   ___/\  XXXXXX            /  ___--/= ' + "\n" +
          '//   \-\    ___/    XXXXXX              "--- XXXXXX ' + "\n" +
          '//      \-\/XXX\ XXXXXX                      /XXXXX ' + "\n" +
          '//        \XXXXXXXXX   \                    /XXXXX/ ' + "\n" +
          '//         \XXXXXX      >                 _/XXXXX/  ' + "\n" +
          '//           \XXXXX--__/              __-- XXXX/    ' + "\n" +
          '//            -XXXXXXXX---------------  XXXXXX-     ' + "\n" +
          '//               \XXXXXXXXXXXXXXXXXXXXXXXXXX/       ' + "\n" +
          '//                 ""VXXXXXXXXXXXXXXXXXXV""' + "\n"
      end
  end
end