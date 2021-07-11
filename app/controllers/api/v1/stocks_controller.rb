module Api
	module V1
		class StocksController < ApplicationController   
            skip_before_action :verify_authenticity_token
            def index 
                create_json("index") 
                render json: {status: 'SUCCESS', message:'products loaded', items:@structurejson},status: :ok
            end 

            def show
				create_json("show")  
                render json: {status: 'SUCCESS', message:'products loaded', items:@structurejson},status: :ok
			end 

            def create   
                @structurejson          = []
                @items_ids              = []
                @total_price_order      = 0
                @items                  = params[:items]
                @total_price_order      +=params[:deliver_fee].to_f
                @items.each do | item |
                    @deliver_fee        = params[:deliver_fee].to_f
                    @origin             = params[:origin]
                    @product_id         = item[:product_id].to_i
                    @amount             = item[:amount].to_i
                    @product_size       = 0
                    @amount_promo       = 0
                    @total_price        = 0
                    @product            = Product.find_by_id(@product_id)
                    @promotion          = Promotion.find_by_id(@product.promotion_id)
                    if @promotion 
                        @product_size   = ( @amount / @promotion.min_amount ) + @amount
                        @amount_promo   = @amount / @promotion.min_amount 
                        @total_price    = ((@amount * @product.price) - (@amount_promo * @product.price))
                    else    
                        @product_size   = @amount  
                        @total_price    = @amount * @product.price
                    end
                    if @product.stock >=  @product_size 
                        @item = Item.new(product_id: @product.id,amount: @amount, price: @total_price)
                        if @item.save
                            @total_price_order  += @total_price
                            @items_ids          << @item.id
                            atualization_bases_v1(@item)
                        end
                    end
                end
                if @items_ids
                    @items = Item.find(*@items_ids)
                    @stock = Stock.new(deliver_fee: @deliver_fee,total_price: @total_price_order,origin: "API")
                    if @stock.save
                        atualization_stock(@stock) 
                        @items.each do |item|
                            @product    = Product.find_by_id(item.product_id)
                            @promotion  = Promotion.find_by_id(@product.promotion_id)
                            if @promotion
                                @structurejson << {
                                    "id":               @product.id, 
                                    "price":            @product.price,
                                    "name":             @product.description,
                                    "amount":           item.amount,
                                    "total":            item.price,
                                    "promotion": {
                                        "id":           @promotion.id,
                                        "name":         @promotion.name,
                                        "description":  @promotion.description,
                                        "min_amount":   @promotion.min_amount,
                                    }
                                }
                            else
                                @structurejson << {
                                    "id":               @product.id, 
                                    "price":            @product.price,
                                    "name":             @product.description,
                                    "amount":           item.amount,
                                    "total":            item.price,
                                } 
                            end
                        end  
                    end
                end 
                render json: {status: 'SUCCESS', order_number: @stock.number_order, deliver_fee:@stock.deliver_fee,total_price:@stock.total_price,items:@structurejson},status: :ok
                #render json: {status: 'SUCCESS', message:'products loaded', items:@structurejson},status: :ok
                #render json: {status: 'ERROR', message:'products not saved', items:msg},status: :unprocessable_entity 
			end
            def atualization_bases_v1(item)
                @product             = Product.find_by_id(item.product_id)
                @product.stock      -= @product_size
                if @product.stock == 0
                  @product.active    = false
                end
                @product.save
            end
            def atualization_stock(stock)
                @stock = stock
                @stock.number_order = @stock.created_at.strftime("%Y%d%m") + @stock.id.to_s
                @stock.save
            end
            private

            def create_json(method)
                case method 
                when "index"  
                    products = Product.where(stock: 1..Float::INFINITY,active: true)
                when "show"
                    products = Product.where(id: params[:id])
                when "create" 
                    order = Stock.find_by_id(@id_order) 
                    products = Product.where(id: order.product_id)
                end
                if method == 'index' or method == 'show'
                    @structurejson = []
                    products.each do | product | 
                        @promotion = Promotion.find_by_id(product.promotion_id)
                        if @promotion
                            @structurejson << {
                                "id":               product.id, 
                                "price":            product.price,
                                "description":      product.description,
                                "stock":            product.stock, 
                                "promotion": {
                                    "id":           @promotion.id,
                                    "name":         @promotion.name,
                                    "description":  @promotion.description,
                                    "min_amount":   @promotion.min_amount,
                                }
                                } 
                        else
                            @structurejson << {
                                "id":               product.id, 
                                "price":            product.price,
                                "description":      product.description,
                                "stock":            product.stock, 
                            } 
                        end
                    end 
                end
            end
		end
	end
end
#Stock(id: , number_order: , deliver_fee: , total_price: , origin: string)
#Promotion(id: , name: , description: , active: , min_amount: )
#Product(id: , description: , stock: , price: , cod_bars: , active: , promotion_id: 