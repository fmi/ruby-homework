def homogenize(items)
  items.group_by(&:class).values
end
