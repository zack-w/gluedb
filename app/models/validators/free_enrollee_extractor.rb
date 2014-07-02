module Validators
  class FreeEnrolleeExtractor
    def initialize(ceiling)
      @ceiling = ceiling
    end

    def extract_from!(enrollees)
      return [] if(enrollees.count <= 5)
      how_many_free = enrollees.count - 5

      sorted = sort_by_oldest(enrollees)
      sorted.pop(how_many_free)
    end

    def sort_by_oldest(enrollees)
      enrollees.sort! { |x, y| y.age <=> x.age }
    end
  end
end