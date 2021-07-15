module Api
	module V1
		class StocksController < ApplicationController    
            skip_before_action :verify_authenticity_token
            def index 
                create_json("index") 
                render json: {status: 'SUCCESS', message:'products loaded', items:@structurejson},status: :ok
            end 
            ################################# edit-block #################################
            #def edit
            #    set_stock
            #    if @stock
            #        create_json("edit") 
            #        @structurejson          = [] 
            #        @items_recipe_params    = params[:items] 
            #        @items                  = Item.where(stock_id: @stock.id)
            #        @products               = Product.where(id: @items.map(&:product_id))
            #        @items_recipe_params.each do | item | 
            #            @item               = Item.find(item[:id])
            #            if item[:product_id] == @item.product_id
            #                if item[:amount] == item[:amount]
            #                    # nenhum parametro mudou,  verifc entrega
            #                    @stock.deliver_fee      = params[:deliver_fee].to_f if @stock.deliver_fee != params[:deliver_fee].to_f
            #                    @stock.save             = if @stock.deliver_fee != params[:deliver_fee].to_f
            #                else
            #                    atualization_item(item,"amount!=")
            #                end
            #            else
            #                if item[:amount] == item[:amount] 
            #                else 
            #                end
            #            end
            #
            #        end
            #        render json: {status: 'SUCCESS', message:'edit'},status: :ok
            #    else
            #        render json: {status: 'ERROR', message:'That order not exist on aplication'},status: :ok
            #    end
			#end 
            #def atualization_item(item, action) 
            #    @product = Product.find(item[:id])
            #    calc(item, action) 
            #end
            #
            #def calc(item, action) 
            #    @item = Item.find(item[:id])
            #    @product_id         = item[:product_id].to_i 
            #    @amount             = item[:amount].to_i 
            #    @amount_promo       = 0
            #    @total_price        = 0
            #    @product            = Product.find_by_id(@product_id)
            #    @promotion          = Promotion.find_by_id(@product.promotion_id) 
            #    if @promotion 
            #        @amount_promo   = @amount / @promotion.min_amount 
            #        if @amount_promo >= 1
            #            @total_price    = (@amount - @amount_promo) * @product.price
            #            @has_prom       = true
            #        else 
            #            @total_price    = @amount * @product.price
            #            @has_prom       = false
            #        end
            #    else     
            #        @total_price    = @amount * @product.price
            #        @has_prom       = false
            #    end
            #    if @product.stock >=  @amount
            #        @item.product_id        = @product.id
            #        @item.amount            = @amount
            #        @item.price             = @total_price
            #        @item.promotion_amount  = @amount_promo
            #        @item.promotion         = @has_prom
            #        if @item.save
            #            @total_price_order  += @total_price
            #            atualization_bases_v1(@item)
            #        end
            #    end
            #end
            ################################## edit-block #################################
            def show
                if params[:id]
                    set_stock
                    if @stock
                        create_json("show_order")
                        render json: {status: 'SUCCESS', order_number: @stock.number_order, deliver_fee:@stock.deliver_fee,total_price:@stock.total_price,create_at:@stock.created_at.strftime('%d-%m-%Y %H:%M'),order:@structurejson},status: :ok
                    else
                        render json: {status: 'ERROR', message:'That order not send for api'},status: :ok
                    end
                else
                    create_json("show")  
                    render json: {status: 'SUCCESS', message:'products loaded', items:@structurejson},status: :ok
                end
			end 
            def create   
                @structurejson          = []
                @items_ids              = []
                @total_price_order      = 0
                @items                  = params[:items]
                @total_price_order      +=params[:deliver_fee].to_f
                if @items != nil 
                    @items.each do | item |
                        @deliver_fee        = params[:deliver_fee].to_f
                        @origin             = params[:origin]
                        @product_id         = item[:product_id].to_i
                        @amount             = item[:amount].to_i 
                        @amount_promo       = 0
                        @total_price        = 0
                        @product            = Product.find_by_id(@product_id)
                        @promotion          = Promotion.find_by_id(@product.promotion_id) 
                        if @promotion 
                            @amount_promo   = @amount / @promotion.min_amount 
                            if @amount_promo >= 1
                                @total_price    = (@amount - @amount_promo) * @product.price
                                @has_prom       = true
                            else 
                                @total_price    = @amount * @product.price
                                @has_prom       = false
                            end
                        else     
                            @total_price    = @amount * @product.price
                            @has_prom       = false
                        end
                        if @product.stock >=  @amount
                            @item = Item.new(product_id: @product.id,amount: @amount, price: @total_price,promotion_amount: @amount_promo, promotion: @has_prom)
                            if @item.save
                                @total_price_order  += @total_price
                                @items_ids          << @item.id
                                atualization_bases_v1(@item)
                            end
                        end
                    end
                else
                    render json: {status: 'ERROR', message:'order no have products'},status: :unprocessable_entity 
                end 
                if @items_ids.size > 0
                    if @items_ids.size == 1 
                        @items = Item.where(id: @items_ids[0])
                    else 
                        @items = Item.find(*@items_ids)
                    end
                    @stock = Stock.new(deliver_fee: @deliver_fee,total_price: @total_price_order,origin: "API")
                    if @stock.save
                        atualization_stock(@stock) 
                        puts 
                        @items.each do |item|
                            item.stock_id = @stock.id
                            item.save
                        end  
                        create_json("create")
                    end
                    render json: {status: 'SUCCESS', order_number: @stock.number_order, deliver_fee:@stock.deliver_fee,total_price:@stock.total_price,items:@structurejson},status: :ok
                else
                    render json: {status: 'ERROR', message:'No have products in stock'},status: :unprocessable_entity 
                end
			end

            def atualization_bases_v1(item)
                @product             = Product.find_by_id(item.product_id)
                @product.stock      -= @amount
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
             

            private ####################################### 
            
            def set_stock
                @stock = Stock.where(number_order: params[:id]).take
            end
            def create_json(method)
                case method 
                when "index"  
                    products = Product.where(stock: 1..Float::INFINITY,active: true)
                when "show"
                    products = Product.where(id: params[:id])
                when "show_order" 
                    @items = Item.where(stock_id: @stock.id)
                    products = Product.where(id: params[:id])
                when "create" 
                    @items = Item.where(stock_id: @stock.id)
                    products = Product.where(id: params[:id]) 
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
                if method == "show_order" or method ==  "create"
                    @structurejson = [] 
                    @items.each do |item| 
                        @product    = Product.find_by_id(item.product_id)
                        @promotion  = Promotion.find_by_id(@product.promotion_id)
                        if @promotion
                            if item.amount >= @promotion.min_amount
                                @structurejson << {
                                    "id":               @product.id, 
                                    "price":            @product.price,
                                    "name":             @product.description,
                                    "amount":           item.amount,
                                    "total":            item.price,
                                    "created":          item.created_at, 
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
                                    "created":          item.created_at, 
                                } 
                            end
                        else
                            @structurejson << {
                                    "id":               @product.id, 
                                    "price":            @product.price,
                                    "name":             @product.description,
                                    "amount":           item.amount,
                                    "total":            item.price,
                                    "created":          item.created_at, 
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