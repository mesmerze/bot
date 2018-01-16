# frozen_string_literal: true

# Copyright (c) 2008-2013 Michael Dvorkin and contributors.
#
# Fat Free CRM is freely distributable under the terms of MIT license.
# See MIT-LICENSE file or http://www.opensource.org/licenses/mit-license.php
#------------------------------------------------------------------------------

# Converts a String to a Boolean value.
#
# Examples:
#   "true".to_bool   #=> true
#   "yes".to_bool    #=> true
#   "t".to_bool      #=> true
#   "y".to_bool      #=> true
#   "1".to_bool      #=> true
#   "false".to_bool  #=> false
#   "no".to_bool     #=> false
#   "f".to_bool      #=> false
#   "n".to_bool      #=> true
#   "0".to_bool      #=> false
#   "foo".to_bool    #=> nil
class String
  def to_bool
    case self
    when /\A(true|t|yes|y|1)\z/i then true
    when /\A(false|f|no|n|0)\z/i then false
    end
  end

  def true?
    to_bool.true?
  end

  def false?
    to_bool.false?
  end
end

# Converts a Fixnum to a Boolean value.
#
# Examples:
#   1.to_bool    #=> true
#   1.0.to_bool  #=> true
#   0.to_bool    #=> false
#   0.0.to_bool  #=> false
#   2.to_bool    #=> nil
#   1.1.to_bool  #=> nil
#   -1.to_bool   #=> nil
class Numeric
  def to_bool
    case self
    when 1 then true
    when 0 then false
    end
  end

  def true?
    to_bool.true?
  end

  def false?
    to_bool.false?
  end
end

class TrueClass
  def to_bool
    self
  end

  def true?
    true
  end

  def false?
    false
  end
end

class FalseClass
  def to_bool
    self
  end

  def true?
    false
  end

  def false?
    true
  end
end

class NilClass
  def to_bool
    self
  end

  def true?
    false
  end

  def false?
    false
  end
end
