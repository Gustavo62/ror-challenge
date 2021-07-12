class StocksController < ApplicationController
  before_action :set_stock, only: %i[ show edit update destroy ]

  # GET /stocks or /stocks.json
  def index   
    @per_pages = Stock.all.size
    if @per_pages >= 5
      @per_pages = 5
    else
      @per_pages = 1 if @per_pages == 0
    end 
    @stocks = Stock.page(4).per(2)
    @products = Product.all
    if params[:id] 
      @per_pages = Stock.all.size
      if @per_pages >= 5
        @per_pages = 5
      end 
      if params[:id] != ''
        @stocks = Stock.where(number_order: params[:id]).page(1)
        if @stocks == nil 
          @stocks = Stock.page(params[:page]).per(@per_pages)
        end
      else 
        @stocks = Stock.page(params[:page]).per(@per_pages)
      end
    else 
      @stocks = Stock.page(params[:page]).per(@per_pages)
    end
  end
  def show
  end
  private 
    # Use callbacks to share common setup or constraints between actions.
    def set_stock
      @stock = Stock.find(params[:id])
    end

    # Only allow a list of trusted parameters through.
    def stock_params 
      params.require(:stock).permit(:number_order, :deliver_fee , :total_price ,:product_id, :amount,:origin)
    end
end
