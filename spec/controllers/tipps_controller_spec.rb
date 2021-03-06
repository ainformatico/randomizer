require 'rails_helper'

RSpec.describe TippsController, :type => :controller do
   
  describe "If User is logged in..." do 

    before(:each) do  
      user = FactoryGirl.create(:user)
      sign_in user   
    end

    it "Is directed to the Index" do
      get :index
      expect(response).to render_template("index")
    end
    
    it "is shown the New form" do
      get :new 
      expect(response).to render_template("new")   
    end

    context"when creating a new Tipp..."do

      before(:each)do 
        @city = FactoryGirl.create(:city)
        @user = FactoryGirl.create(:user)
      end

      it "can create a correct Tipp" do
        post :create, tipp: {name: "A Place", streetname: "A Street", user_id: @user.id, city_id: @city.id}
       
        expect(response).to have_http_status(302)
      end

      it "is offered to add a comment to the Tipp" do
        post :create, tipp: {name: "A Place", streetname: "A Street", user_id: @user.id, city_id: @city.id}

        expect(flash[:addcomment]).to be_truthy      
      end
      
      it "is notified when the Tipp exists" do
        @tipp = FactoryGirl.create(:tipp, name:"A Place")

        post :create, tipp: {name: "A Place", streetname: "A Street", user_id: @user.id, city_id: @city.id}
      

        expect(flash[:taken]).to be_truthy
      end

      it "is noticed when form is incorrect" do 
        post :create, tipp: {name: "A Place", streetname: "A Street", user_id: nil, city_id: @city.id}
        expect(flash[:error]).to be_truthy
      end

      it "redirected back when form is incorrect" do 
        post :create, tipp: {name: nil, streetname: "A Street", user_id: @user.id, city_id: @city.id}
        expect(response).to redirect_to(new_tipp_path)
      end
    end
  end 

  describe "If user is not logged in..." do

    it "is directed to the Index" do
    get :index
    expect(response).to render_template("index")
    end

    context "it is redirected to new_user_path when..." do
      
      it "tries to create a new Tipp" do
        get :new 
        expect(response).to redirect_to(new_user_session_path)
      end   
    end    
  end
end  