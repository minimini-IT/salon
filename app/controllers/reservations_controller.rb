# frozen_string_literal: true

class ReservationsController < ApplicationController
  def index
    @menus = Menu.all
    @cut = MenuContent.where(menu_id: 1)
    @perm = MenuContent.where(menu_id: 2)
    @color = MenuContent.where(menu_id: 3)
    @today = Date.today
    @next_month = @today.next_month
    @days = [*@today.beginning_of_month.day..@today.end_of_month.day]
    @day = @today.day
    @hour = [*10..18]
    @min = [":00", ":30"]
    @time = []
    @hour.each do |h|
      @min.each do |m|
        @time << "#{h}#{m}"
      end
    end
    @ajax_mon = params[:month]
    @ajax_day = params[:day]

    if @ajax_mon.present?
#      logger.debug("--------------------------")
      logger.debug({month: @ajax_mon})
      logger.debug({day: @ajax_day})
      if @ajax_mon == "1"
        day_week(@today.next_year.year.to_i, @ajax_mon.to_i, @ajax_day.to_i)
      else
        day_week(@today.year.to_i, @ajax_mon.to_i, @ajax_day.to_i)
      end
    else
      #logger.debug("--------------------------")
      #logger.debug("no ajax")
      day_week(@today.year.to_i, @today.month.to_i, @day.to_i)
    end
  end

  def create
    @month = params[:month]
    @day = params[:day]
    @time = params[:time]
    @menu = MenuContent.all
    @reservations = Reservation.new
  end

  def add
    params[:reservation][:menu] = params[:reservation][:menu].join(',')
    # render plain: params[:reservation].inspect
    @reservations = Reservation.new(strong_params)
    if @reservations.save
      redirect_to reservations_path
    else
      # render：viewを明示的に指定
      render 'index'
    end
  end

  private

  def strong_params
    params.require(:reservation).permit(:name, :menu, :start_time, :end_time, :name_kana, :tel)
  end

  def day_week(year, month, day)
      #logger.debug("********************************")
      #logger.debug({year: year})
    # 予約済み時間
    @reserved_time = []
    # 予約時間
    @reservation_time_default = [
      '10:00',
      '10:30',
      '11:00',
      '11:30',
      '12:00',
      '12:30',
      '13:00',
      '13:30',
      '14:00',
      '14:30',
      '15:00',
      '15:30',
      '16:00',
      '16:30',
      '17:00',
      '17:30',
      '18:00',
      '18:30'
    ]
    @today = Date.new(year, month, 1)
    @days_date = [*@today.beginning_of_month..@today.end_of_month]
    @days = [*@today.beginning_of_month.day..@today.end_of_month.day]
    @weekly = []
    @days_date.each do |d|
      @weekly << %w(日 月 火 水 木 金 土)[d.wday]
    end
    @days_weekly = [@days, @weekly].transpose
    @days_weekly_hash = Hash[*@days_weekly.flatten]
    @days_weekly_hash.delete_if{ |k, v| v == "月"}
    @tuesday = []
    @tuesday << @days_weekly_hash.select{ |k, v| v == "火"}.keys[1]
    if @days_weekly_hash.select{ |k, v| v == "火"}.keys.length >= 4
      @tuesday << @days_weekly_hash.select{ |k, v| v == "火"}.keys[3]
    end
    @days_weekly_hash.delete(@tuesday[0])
    if @tuesday[1] != nil
      @days_weekly_hash.delete(@tuesday[1]) 
    end
    @days = @days_weekly_hash.keys
    if @ajax_mon && @ajax_day
      # 検索する年月日
      search_date = year.to_s + '-' + month.to_s + '-' + day.to_s
      #logger.debug({search_date: search_date})
      # search_dateを元にその年月日の予約を取り出す
      @reservation = Reservation.select('start_time').where(start_time: search_date.in_time_zone.all_day)
      #logger.debug({reservation: @reservation})
      # 予約済みの時間を取り出す
      @reservation.each do |r|
        if r.start_time.min.to_s == "0"
          @min = r.start_time.min.to_s + "0"
          @reserved = r.start_time.hour.to_s + ':' + @min
        else
          @reserved = r.start_time.hour.to_s + ':' + r.start_time.min.to_s
        end
        #logger.debug("****************************************")
        #logger.debug({reserved: @reserved})
        reserved_index = @reservation_time_default.index(@reserved)
        @reserved_time << @reserved
        @reserved_time << @reservation_time_default[reserved_index.to_i + 1]
      end
      # 予約済み時間を引く
      @reservation_time = @reservation_time_default - @reserved_time
      #logger.debug({reserved_time: @reserved_time})
      #logger.debug({reservation_time: @reservation_time})
      #logger.debug({reservation_time_default: @reservation_time_default})
      render json: {
        time: @reservation_time,
        days: @days,  
        day: day
      }
      return @days
    end
  end

end
