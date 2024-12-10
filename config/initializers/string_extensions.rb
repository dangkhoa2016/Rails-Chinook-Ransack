
module StringExtensions
  def to_yes_no
    case self.downcase
    when 'true', 'yes', '1'
      true
    when 'false', 'no', '0'
      false
    else
      nil
    end
  end
end

String.include StringExtensions
