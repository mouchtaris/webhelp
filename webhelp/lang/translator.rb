module Webhelp
module Lang

class TranslatorError < Exception
end

class Translator
  include Util::ArgumentChecking

  def new_yaml_loader db_files
    Util::YamlLoader.new *db_files
  end
  private :new_yaml_loader

  # @param translations [Hash<Symbol,Array<String>>]
  #     files of mappings of translations for each
  #     language
  def initialize translations
    @translations = translations.map do |lang, files|
      [lang, new_yaml_loader(files)]
    end
    reload!
  end

  def reload!
    @db = @translations.map do |lang, loader|
      [lang, loader.reload]
    end.to_h.deep_freeze
  end

  def translate id, lang = nil
    use_lang = lang || @lang
    language_translations = @db[use_lang]
    raise TranslatorError.new "No such laguage: #{lang.inspect}" unless language_translations
    case result = language_translations[id]
      when Array then
        method_name = result.first.to_sym
        method = method method_name
        method.call *result[1..-1]
      when String then result
      else raise TranslatorError.new "Invalid translation: #{result.inspect}"
    end
  end

  def lang= lang
    require_symbol{:lang}
    unless @db.has_key? lang then
      raise TranslatorError.new "#{lang.inspect} is not found in languages"
    end
    @lang = lang
  end
  attr_reader :lang

end#class Translator

end#module Lang
end#module Webhelp
