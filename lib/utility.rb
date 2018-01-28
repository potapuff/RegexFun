class NilClass
  def empty?
    true
  end
end

class Regexp
  def empty?
    false
  end
end

class Array
  def rand
    self[Kernel.rand(self.size)]
  end
end

class RegexpGroup

  REPEATER = {
      may_be:"?",
      one:"",
      one_or_more:"+",
      zerro_or_more: "*",
      execly: lambda {i = rand(3)+1; "{#{i}}"},
      more_than: lambda {i = rand(2)+2; "{#{i},}"},
      no_more_than: lambda {i = rand(2)+2; "{,#{i}}"},
  }
  MODIFIER = [:yes, :no]
  ALPHABET = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz1234567890".split('').freeze

  attr_accessor :repeater, :modifier
  attr_accessor :text

  def initialize
    @repeater  = REPEATER.keys.rand
    @modifier  = rand > 0.8 ? MODIFIER[0] : MODIFIER[1]
  end

  def build
    repeater = REPEATER[@repeater]
    text+ (repeater.is_a?(String) ? repeater : repeater.call)
  end

  def self.descendants
    ObjectSpace.each_object(Class).select { |klass| klass < self }
  end
end

class DigitGroup < RegexpGroup
  def text
    @text ||= @modifier == :yes ? '\d' : '\D'
  end
end

class LetterGroup < RegexpGroup
  def text
    @text ||= @modifier == :yes ? '[A-z]' : '[^A-z]'
  end
end

class WordGroup < RegexpGroup
  def text
    @text ||= @modifier == :yes ? '\w' : '\W'
  end
end

class AnyGroup < RegexpGroup
  def text
    @text ||= '.'
  end
end

class SubLetterGroup < RegexpGroup
  def text
    text = ALPHABET.dup.shuffle[1..(rand(4)+2)].join('')
    @text ||= @modifier == :yes ? "[#{text}]" : "[^#{text}]"
  end
end

class OneLetterGroup < RegexpGroup
  def text
    letter = ALPHABET.rand
    @text ||= @modifier == :yes ? letter : "[^#{letter}]"
  end
end

class RegexpTask

  attr_accessor :regexp
  attr_accessor :raw

  def initialize
    @raw = +''
    (rand(3)+2).times do |_i|
      @raw << RegexpGroup.descendants.rand.new.build
    end
    @regexp = Regexp.compile('\A'+@raw+'\Z')
  end

  def to_s
    @regexp.to_s
  end

  ALPHABET = RegexpGroup::ALPHABET.dup + ('0'..'9').to_a + [' ']
  def self.find_different(task_regexp, other_regexp)
    10000.times do
      example = +''
      (rand(7)+4).times {example << ALPHABET.rand}
      return example if (task_regexp =~ example) != (other_regexp =~ example)
    end
    nil
  end
end
