# frozen_string_literal: true

class AccountsController < ApplicationController
  before_action :set_account, only: %i[edit update destroy]

  before_action :authenticate_account!, except: [:current]

  # GET /accounts
  # GET /accounts.json
  def index
    @accounts = Account.all
  end

  # GET /accounts/current.json
  def current
    current_doorkeeper_account = Account.find(doorkeeper_token.resource_owner_id) if doorkeeper_token

    respond_to do |format|
      format.json { render json: current_doorkeeper_account }
    end
  end

  # GET /accounts/1/edit
  def edit; end

  # PATCH/PUT /accounts/1
  # PATCH/PUT /accounts/1.json
  # rubocop:disable Metrics/AbcSize, Metrics/MethodLength
  def update
    respond_to do |format|
      new_role = @account.role == account_params[:role] ? nil : account_params[:role]

      if @account.update(account_params)
        # ----------------------------- produce event -----------------------
        producer = WaterDrop::Producer.new do |config|
          config.deliver = true
          config.kafka = {
            'bootstrap.servers': ENV.fetch('KAFKA_URL'),
            'request.required.acks': 1
          }
        end

        event = {
          event_name: 'AccountsUpdated',
          event_id: SecureRandom.uuid,
          event_version: 1,
          event_time: Time.now.to_s,
          producer: 'auth_service',
          data: {
            public_id: @account.public_id,
            email: @account.email,
            full_name: @account.full_name,
            position: @account.position
          }
        }
        result = SchemaRegistry.validate_event(event, 'accounts.updated', version: 1)

        if result.success?
          producer.produce_sync(payload: event.to_json, topic: 'accounts-stream')
        else
          logger.error('Invalid payload for "accounts-stream" event: ' + result.failure.join('; '))
          # store events in DB or produce invalid event to "invalid-events-topic"
        end

        if new_role
          event = {
            event_name: 'AccountsRoleChanged',
            event_id: SecureRandom.uuid,
            event_version: 1,
            event_time: Time.now.to_s,
            producer: 'auth_service',
            data: { public_id: @account.public_id, role: @account.role }
          }

          result = SchemaRegistry.validate_event(event, 'accounts.role_changed', version: 1)

          if result.success?
            producer.produce_sync(payload: event.to_json, topic: 'accounts')
          else
            logger.error('Invalid payload for "accounts" event: ' + result.failure.join('; '))
            # store events in DB or produce invalid event to "invalid-events-topic"
          end
        end

        producer.close
        # --------------------------------------------------------------------

        format.html { redirect_to accounts_path, notice: 'Account was successfully updated.' }
        format.json { render :index, status: :ok, location: @account }
      else
        format.html { render :edit }
        format.json { render json: @account.errors, status: :unprocessable_entity }
      end
    end
  end
  # rubocop:enable Metrics/AbcSize, Metrics/MethodLength

  # DELETE /accounts/1
  # DELETE /accounts/1.json
  #
  # in DELETE action, CUD event
  def destroy
    @account.update(active: false, disabled_at: Time.zone.now)

    # ----------------------------- produce event -----------------------
    producer = WaterDrop::Producer.new do |config|
      config.deliver = true
      config.kafka = {
        'bootstrap.servers': ENV.fetch('KAFKA_URL'),
        'request.required.acks': 1
      }
    end

    event = {
      event_name: 'AccountsDeleted',
      event_id: SecureRandom.uuid,
      event_version: 1,
      event_time: Time.now.to_s,
      producer: 'auth_service',
      data: { public_id: @account.public_id }
    }

    result = SchemaRegistry.validate_event(event, 'accounts.deleted', version: 1)

    if result.success?
      producer.produce_sync(payload: event.to_json, topic: 'accounts-stream')
    else
      logger.error('Invalid payload for "accounts-stream" event: ' + result.failure.join('; '))
      # store events in DB or produce invalid event to "invalid-events-topic"
    end

    producer.close
    # --------------------------------------------------------------------

    respond_to do |format|
      format.html { redirect_to accounts_path, notice: 'Account was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private

  # Use callbacks to share common setup or constraints between actions.
  def set_account
    @account = Account.find(params[:id])
  end

  # Only allow a list of trusted parameters through.
  def account_params
    params.require(:account).permit(:full_name, :role, :position)
  end
end
