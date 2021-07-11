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
                @product_ids = params[:product_id]
                @product_size = 0
                @product_ids.each do | prod_id |
                    products  = Product.find_by_id(prod_id)
                    promotion = Promotion.find_by_id(prod_id) 
                    @amount_promo = 0
                    @p_amount = params[:amount].to_i
                    if promotion 
                        @product_size = ( @p_amount / promotion.min_amount ) + @p_amount
                    end
                    if products.stock >=  @product_size
                        if promotion
                            if @p_amount > promotion.min_amount
                                @amount_promo = @p_amount / promotion.min_amount 
                                params[:amount] = @p_amount + @amount_promo
                                params[:total_price] = (((@p_amount * products.price) - (products.price * @amount_promo)) + params[:deliver_fee].to_f)
                            else
                                params[:total_price] = ((@p_amount * products.price) + params[:deliver_fee].to_f)
                            end
                        else
                            params[:total_price] = ((@p_amount * products.price) + params[:deliver_fee].to_f)
                        end
                        stock = Stock.new(total_price: params[:total_price],amount: params[:amount],deliver_fee: params[:deliver_fee],origin: "API",product_id: prod_id)
                        if stock.save 
                            atualization_bases(stock)
                            @id_order = stock.id 
                            create_json("create")   
                        end
                    else 
                        msg = []
                        if promotion
                            @msg_aux = " ,have #{@p_amount / promotion.min_amount} promotion's."
                        else
                            @msg_aux = "."
                        end
                        msg << {"ALERT": "Stock for this product is #{products.stock} and your order there is #{@product_size}#{@msg_aux}"} 
                

                        
                    end
                end
                
                render json: {status: 'SUCCESS', message:'products loaded', items:@structurejson},status: :ok
                render json: {status: 'ERROR', message:'products not saved', items:msg},status: :unprocessable_entity 
                
			end
            def atualization_bases(object)
                @stock = object
                @stock.number_order = @stock.created_at.strftime("%Y%d%m") + @stock.id.to_s
                @product = Product.find_by_id(@stock.product_id)
                @product.stock = @product.stock - @stock.amount
                if @product.stock == 0
                  @product.active = false
                end
                @product.save
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
                else
                    @structurejson = []
                    products.each do | product | 
                        @promotion = Promotion.find_by_id(product.promotion_id)
                        if @promotion
                            @structurejson << {
                                "order": order,
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
#Stock(id: , number_order: , deliver_fee: , total_price: , product_id: , amount: integer, origin: string)
#Promotion(id: , name: , description: , active: , min_amount: )
#Product(id: , description: , stock: , price: , cod_bars: , active: , promotion_id: 