Feature: User can create an account
	As a user I would like to be able to create a new account.
	
Scenario: Create an Account
	When I create a user with username "konker" and password "password"
	Then I should see "konker"