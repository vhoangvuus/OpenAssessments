require 'rails_helper'

describe Api::ItemResultsController do

  before do
    @account = FactoryGirl.create(:account)
    @user = FactoryGirl.create(:user, account: @account)
    @user.confirm!
    
    @admin = CreateAdminService.new.call
    @admin.make_account_admin({account_id: @account.id})

    @user_token = AuthToken.issue_token({ user_id: @user.id })
    @admin_token = AuthToken.issue_token({ user_id: @admin.id })

    allow(controller).to receive(:current_account).and_return(@account)
  end

  describe "GET 'index'" do
    before do
      request.headers['Authorization'] = @admin_token
      @item = FactoryGirl.create(:item)
      @result1 = FactoryGirl.create(:item_result, item: @item)
      @result2 = FactoryGirl.create(:item_result, item: @item, referer: 'www.example.com')
      @result3 = FactoryGirl.create(:item_result, item: @item, referer: 'www.example.com/index.html')
      @result4 = FactoryGirl.create(:item_result, item: @item)
      @result4.objective_list.add('goal')
      @result4.objective_list.add('bar')
      @result4.save!
      @result5 = FactoryGirl.create(:item_result, item: @item)
      @result5.objective_list.add('goal')
      @result5.save!
    end

    it "returns http success" do
      get :index, format: :json, id: @item.id
      expect(response).to have_http_status(200)
    end

    it "scopes results" do
      get :index, format: :json, id: @item.id, scope: 'domain', url: 'www.example.com/index'
      result = JSON.parse(response.body)
      expect(result.map{|i|i['id']}.sort).to eq [@result2.id, @result3.id].sort
    end

    it "filters by objective" do
      get :index, format: :json, objective: 'goal, bar'
      result = JSON.parse(response.body)
      expect(result.first['id']).to eq(@result4.id)
    end

    it "renders results as csv" do
      get :index, format: :csv, id: @item.id
      result = response.body
    end

    it "renders results as xml" do
      get :index, format: :xml, id: @item.id
      expect(response.body).to include('xml')
    end

    it "scopes summarized results" do
      get :index, format: :json, id: @item.id, type: 'summary', scope: 'page', url: 'www.example.com/index'
      expect(JSON(response.body)['renders']).to eq 1
    end
  end

  describe "POST create" do
    before do
      request.headers['Authorization'] = @admin_token
    end
    it "creates an item" do
      item_result = FactoryGirl.build(:item_result)
      post :create, id: item_result.id, confidence_level: "Maybe?", format: :json
      expect(ItemResult.first).to_not be(nil)
      expect(ItemResult.first.confidence_level).to eq(1)
    end
    it "creates an item with a src_url" do
      item_result = FactoryGirl.build(:item_result)
      post :create, id: item_result.id, src_url: "foo", format: :json
      expect(ItemResult.first).to_not be(nil)
      expect(ItemResult.first.src_url).to eq("foo")
    end
    it "creates an item with keywords" do
      item_result = FactoryGirl.build(:item_result)
      post :create, id: item_result.id, keywords: "foo, bar", format: :json
      expect(ItemResult.first).to_not be(nil)
      expect(ItemResult.first.keyword_list).to include("foo")
      expect(ItemResult.first.keyword_list).to include("bar")
    end
  end

end
