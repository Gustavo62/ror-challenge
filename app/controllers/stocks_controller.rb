class StocksController < ApplicationController
  before_action :set_stock, only: %i[ show edit update destroy ]

  # GET /stocks or /stocks.json
  def index  
    @per_pages = Stock.all.size
    if @per_pages >= 5
      @per_pages = 5
    end 
    @stocks = Stock.page(4).per(2)
    @products = Product.all
    if params[:id] 
      if params[:id] != ''
        @stocks = Stock.where(number_order: params[:id])
        if @stocks == nil 
          @stocks = Stock.all.page(@per_pages)
        end
      else 
        @stocks = Stock.all.page(@per_pages)
      end
    else 
      @stocks = Stock.page(params[:page]).per(5)
    end
  end

  # GET /stocks/1 or /stocks/1.json
  def show
  end

  # GET /stocks/new
  def new
    @stock = Stock.new 
    @products = Product.where(active: true) 
  end

  # GET /stocks/1/edit
  def edit
  end

  # POST /stocks or /stocks.json
  def create
    @stock = Stock.new(stock_params) 
    respond_to do |format|
      if @stock.save 
        atualization_bases(@stock)
        format.html { redirect_to stocks_url, notice: "Stock was successfully created." }
        format.json { head :no_content }
      else
        format.html { render :new, status: :unprocessable_entity }
        format.json { render json: @stock.errors, status: :unprocessable_entity }
      end
    end 
  end

  # PATCH/PUT /stocks/1 or /stocks/1.json
  def update
    respond_to do |format|
      if @stock.update(stock_params)
        format.html { redirect_to @stock, notice: "Stock was successfully updated." }
        format.json { render :show, status: :ok, location: @stock }
      else
        format.html { render :edit, status: :unprocessable_entity }
        format.json { render json: @stock.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /stocks/1 or /stocks/1.json
  def destroy
    @stock.destroy
    respond_to do |format|
      format.html { redirect_to stocks_url, notice: "Stock was successfully destroyed." }
      format.json { head :no_content }
    end
  end
  def get_data
    @product = Product.find_by_id(params[:id])
    @promotion = Promotion.find_by_id(@product.promotion_id) 
    respond_to do |format|
      format.json { render json: { :product => @product, :promotion => @promotion } }
    end
  end
  def atualization_bases(object)
    @stock.number_order = object.created_at.strftime("%Y%d%m") + object.id.to_s
    @product = Product.find_by_id(object.product_id)
    @product.stock = @product.stock - object.amount
    if @product.stock == 0
      @product.active = false
    end
    @product.save
    @stock.save
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
