class Module
  def all_the_modules
    [self] + constants.map { |const| const_get(const) }
                 .select { |const| const.is_a?(Module) && !const.is_a?(Class) }
                 .flat_map { |const| const.all_the_modules }
  end
end