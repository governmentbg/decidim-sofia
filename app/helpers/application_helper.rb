module ApplicationHelper
  def mask_string(string, all_but = 4, char = '*')
    (string || '').reverse.gsub(/.(?=.{#{all_but}})/, char).reverse
  end
end
