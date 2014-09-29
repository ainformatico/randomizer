require 'rails_helper'

RSpec.describe CommentsController, type: :controller do

  describe 'If User is logged out...' do
    it 'is redirected to signup when accessing the #new form' do
      get :new
      expect(response).to redirect_to(new_user_session_path)
    end
  end

  describe 'If User is logged in..' do

    before(:each) do
      sign_in FactoryGirl.create(:user)
    end

    describe '#new' do
      it 'renders not_found if not tip provided' do
        get :new
        expect(response).to be_not_found
      end

      it 'shows page if tipp provided' do
        tip = FactoryGirl.create(:tipp)
        get :new, tipp_id: tip.id
        expect(assigns(:comment)).to be_an(Comment)
        expect(response).to render_template('new')
        expect(response).to be_success
      end
    end
  end

  describe 'when creating a correct Comment...' do
    describe '#create' do
      it 'it can create a correct comment' do
        create_post_request
        expect(response).to redirect_to(new_tipp_path)
      end

      it 'Notices the user of the success' do
        create_post_request
        expect(flash[:notice]).to be_truthy
      end

      it 'relates the comment to a Tipp' do
        create_post_request
        expect(Comment.last.tipp_id).to eq(@tipp.id)
      end

      it 'relates the comment to a User' do
        create_post_request
        expect(Comment.last.user_id).to eq(@user.id)
      end

      it 'should render not_found if invalid tip' do
        create_post_request(tipp_id: nil)
        expect(response).to be_not_found
      end

      private

      def create_post_request(opts = {})
        owner = FactoryGirl.create(:user)
        @tipp = FactoryGirl.create(:tipp, user: owner)
        @user = FactoryGirl.create(:user, karma: 10)
        sign_in @user

        options = {
          content: 'I love their Tacos!',
          user_id: @user.id,
          tipp_id: @tipp.id
        }.merge!(opts)

        comment_attrs = FactoryGirl.attributes_for(:comment, options)

        post :create, comment: comment_attrs
      end
    end
  end
end
