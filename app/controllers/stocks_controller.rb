class StocksController < ApplicationController
  before_action :set_stock, only: %i[ show edit update destroy ]

  # GET /stocks or /stocks.json
  def index   
    @per_pages = 5 
    @products = Product.all
    if params[:id]  
      if params[:id] != ''
        @stocks = Stock.where(number_order: params[:id]).page(1)
        if @stocks == nil 
          @stocks = Stock.page(params[:page]).per(@per_pages)
        end
      else 
        @stocks = Stock.page(params[:page]).per(@per_pages)
      end
    else 
      @stocks = Stock.order(created_at: :desc).page(params[:page]).per(@per_pages)
    end
  end
  def show 
    @items      =  Item.where(stock_id: @stock.id) 
    get_prods(@items)
    @products   = Product.where(id: @ids_items_recipe)
    @promotions  = Promotion.all
  end
  def get_prods(object)
    @ids_items_recipe = []  

    @items.each do | item |
    	@ids_items_recipe << item.product_id  
    end 
	end
  private 
    # Use callbacks to share common setup or constraints between actions.
    def set_stock
      @stock = Stock.find(params[:id])
    end

    # Only allow a list of trusted parameters through.
    def stock_params 
      params.require(:stock).permit(:number_order, :deliver_fee , :total_price ,:origin)
    end
end
