require 'rails_helper'

feature 'users' do
  include UsersHelper
  include OmniauthHelper

  context 'when not signed in' do
    scenario 'should see link to sign in' do
      visit root_path
      expect(page).to have_link 'Sign in with Github'
    end

    scenario 'redirected to home when trying to access other pages' do
      visit posts_path
      expect(current_path).to eq '/'
    end

    scenario 'should not see link to Resources' do
      visit root_path
      expect(page).not_to have_link 'Resources'
    end

    scenario 'should not be able to delete resources' do
      visit new_post_path
      expect(current_path).to eq '/users/sign_in'
    end

    scenario 'sign in fails if not authenticated' do
      visit root_path
      expect{ click_link 'Sign in with Github' }.to raise_error "Validation failed: Email can't be blank"
    end
  end

  context 'when signed in' do

    before(:each) do
      oauth_sign_in
    end

    after(:each) do
      oauth_sign_out
    end

    scenario 'should see link to resources' do
      expect(page).to have_link 'Resources'
    end

    scenario 'should not see link to sign in' do
      expect(page).not_to have_link 'Sign in with Github'
    end

    scenario 'should see link to sign out' do
      expect(page).to have_link 'Sign out'
    end

    scenario 'can sign out' do
      click_link 'Sign out'
      expect(page).to have_link 'Sign in with Github'
    end

    scenario 'can go to resources page' do
      click_link 'Resources'
      expect(current_path).to eq posts_path
    end

    scenario 'can add a post/resource' do
      click_link 'Resources'
      add_post
      expect(page).to have_content('Ultimate Resource')
      expect(page).to have_content('www.google.com')
      expect(page).to have_content('ruby, makers, beginner')
    end


    scenario 'cannot see delete link unless he created post' do
      Post.create(title: 'resource', link: 'www.link.com', all_tags: 'makers, code')
      click_link 'Resources'
      expect(page).to have_content('www.link.com')
      expect(page).not_to have_content('Delete')
      add_post
      expect(page).to have_content('Ultimate Resource')
      expect(page).to have_link('Delete')
    end

    scenario 'cannot see edit link unless he created post' do
      Post.create(title: 'resource', link: 'www.link.com', all_tags: 'makers, code')
      click_link 'Resources'
      expect(page).to have_content('www.link.com')
      expect(page).not_to have_content('Edit')
      add_post
      expect(page).to have_content('Ultimate Resource')
      expect(page).to have_link('Edit')
    end

    scenario 'can delete post he created' do
      click_link 'Resources'
      add_post
      expect(page).to have_content('Ultimate Resource')
      click_link('Delete')     
      expect(page).not_to have_content('Ultimate Resource')
    end

    scenario 'can edit post he created' do
      click_link 'Resources'
      add_post
      expect(page).to have_content('Ultimate Resource')
      click_link 'Edit'
      fill_in 'Title', with: 'Title has been changed'
      click_button 'Update'
      expect(page).to have_content('Title has been changed')
    end

    scenario 'can only edit comments that he created' do
      click_link 'Resources'
      add_post
      click_link 'Ultimate Resource'
      add_comment
      click_link 'Sign out'
      oauth_sign_out
      oauth_sign_in_2
      click_link 'Resources'
      click_link 'Ultimate Resource'
      click_link 'Edit Comment'
      expect(page).to have_content('Cannot edit a comment you haven\'t created')
    end

    scenario 'can only delete comments that he created' do
      click_link 'Resources'
      add_post
      click_link 'Ultimate Resource'
      add_comment
      click_link 'Sign out'
      oauth_sign_out
      oauth_sign_in_2
      click_link 'Resources'
      click_link 'Ultimate Resource'
      click_button 'Delete Comment'
      expect(page).to have_content('Cannot delete a comment you haven\'t created')
    end
  end
end
