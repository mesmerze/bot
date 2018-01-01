module OrgsHelper
  def revenue(org)
    amount = 0
    org.accounts.each do |acc|
      acc.opportunities.each { |opp| amount += opp.amount }
    end && number_to_currency(amount)
  end
end
