require './models/career'
require './models/trait'

module WorkForwardNola
  module Views
    # logic for career results page
    class Careers < Layout
      @career_matches = []

      attr_reader :title

      def career_count
        @career_matches.count
      end

      def career_descriptions
        # get all the "me" traits
        it_me = @quiz_answers.select { |_trait, ans| ans.eql? 'me' }.keys
        # only select careers that match the "me" traits
        @career_matches = Career.where(traits: Trait.where(name: it_me))
                                .map do |career|
          {
            id: career.id,
            job_title: career.name,
            job_description: career.description,
            foundational_skills: career.foundational_skills,
            training: career.training,
            experienced_wage: to_money(career.experienced_wage),
            certification_required: career.certification_required,
            match_score: trait_match_score(it_me, career.traits)
          }
        end

        @career_matches = @career_matches.sort_by { |career| career[:match_score] }
                                         .reverse
                                         .first(3)
        @career_matches.each.with_index(1) do |match, i|
          match[:index] = i
        end

        @career_matches.first[:first] = true
        @career_matches.last[:last] = true
        @career_matches
      end

      def career_ids
        @career_matches.map { |career| career[:id] }
      end

      private

      def trait_match_score(user_trait_names, career_traits)
        score = 0

        # loop through traits of the career and see how many match the ones the user selected
        career_traits.each do |trait|
          score += 1 if user_trait_names.include?(trait.name)
        end

        score
      end

      # expecting float
      def to_money(amount)
        sprintf '$%.2f', amount
        # if needed, for putting commas in money format:
        # "$#{amount.to_s.gsub(/(\d)(?=(\d\d\d)+(?!\d))/, '\0,')}"
      end
    end
  end
end
