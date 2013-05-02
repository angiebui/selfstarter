# encoding: UTF-8
# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your
# database schema. If you need to create the application database on another
# system, you should be using db:schema:load, not running all the migrations
# from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended to check this file into your version control system.

ActiveRecord::Schema.define(:version => 20130502140108) do

  create_table "campaigns", :force => true do |t|
    t.string   "name"
    t.float    "goal"
    t.datetime "expiration_date"
    t.string   "ct_campaign_id"
    t.string   "media_type",                           :default => "video",      :null => false
    t.string   "main_image_file_name"
    t.string   "main_image_content_type"
    t.integer  "main_image_file_size"
    t.datetime "main_image_updated_at"
    t.string   "video_embed_id"
    t.string   "video_placeholder_file_name"
    t.string   "video_placeholder_content_type"
    t.integer  "video_placeholder_file_size"
    t.datetime "video_placeholder_updated_at"
    t.string   "contributor_reference",                :default => "backer"
    t.string   "progress_text",                        :default => "funded"
    t.string   "primary_call_to_action_button",        :default => "Contribute"
    t.text     "primary_call_to_action_description"
    t.string   "secondary_call_to_action_button",      :default => "Contribute"
    t.text     "secondary_call_to_action_description"
    t.text     "main_content"
    t.text     "checkout_sidebar_content"
    t.text     "confirmation_page_content"
    t.text     "confirmation_email_content"
    t.string   "payment_type",                         :default => "any",        :null => false
    t.float    "min_payment_amount",                   :default => 1.0,          :null => false
    t.float    "fixed_payment_amount",                 :default => 1.0,          :null => false
    t.boolean  "apply_processing_fee",                 :default => false,        :null => false
    t.boolean  "collect_shipping_address",             :default => false,        :null => false
    t.string   "tweet_text"
    t.string   "facebook_title"
    t.text     "facebook_description"
    t.string   "facebook_image_file_name"
    t.string   "facebook_image_content_type"
    t.integer  "facebook_image_file_size"
    t.datetime "facebook_image_updated_at"
    t.string   "slug"
    t.datetime "created_at",                                                     :null => false
    t.datetime "updated_at",                                                     :null => false
    t.integer  "stats_number_of_contributions"
    t.integer  "stats_raised_amount"
    t.float    "stats_tilt_percent"
    t.integer  "stats_unique_contributors"
    t.boolean  "is_expired"
    t.boolean  "is_tilted"
    t.boolean  "is_paid"
    t.boolean  "archive_flag",                         :default => false,        :null => false
    t.boolean  "collect_shipping",                     :default => false,        :null => false
  end

  add_index "campaigns", ["slug"], :name => "index_campaigns_on_slug", :unique => true

  create_table "ckeditor_assets", :force => true do |t|
    t.string   "data_file_name",                  :null => false
    t.string   "data_content_type"
    t.integer  "data_file_size"
    t.integer  "assetable_id"
    t.string   "assetable_type",    :limit => 30
    t.string   "type",              :limit => 30
    t.integer  "width"
    t.integer  "height"
    t.datetime "created_at",                      :null => false
    t.datetime "updated_at",                      :null => false
  end

  add_index "ckeditor_assets", ["assetable_type", "assetable_id"], :name => "idx_ckeditor_assetable"
  add_index "ckeditor_assets", ["assetable_type", "type", "assetable_id"], :name => "idx_ckeditor_assetable_type"

  create_table "faqs", :force => true do |t|
    t.text     "question"
    t.text     "answer"
    t.integer  "sort_order"
    t.datetime "created_at",  :null => false
    t.datetime "updated_at",  :null => false
    t.integer  "campaign_id"
  end

  create_table "orders", :id => false, :force => true do |t|
    t.string   "token"
    t.string   "transaction_id"
    t.string   "address_one"
    t.string   "address_two"
    t.string   "city"
    t.string   "state"
    t.string   "zip"
    t.string   "country"
    t.string   "status"
    t.string   "number"
    t.string   "uuid"
    t.string   "user_id"
    t.decimal  "price"
    t.decimal  "shipping"
    t.string   "tracking_number"
    t.string   "phone"
    t.string   "name"
    t.date     "expiration"
    t.datetime "created_at",        :null => false
    t.datetime "updated_at",        :null => false
    t.integer  "payment_option_id"
  end

  create_table "payment_options", :force => true do |t|
    t.decimal  "amount"
    t.string   "amount_display"
    t.text     "description"
    t.string   "shipping_desc"
    t.string   "delivery_desc"
    t.integer  "limit"
    t.datetime "created_at",     :null => false
    t.datetime "updated_at",     :null => false
  end

  create_table "payments", :force => true do |t|
    t.string   "ct_payment_id"
    t.string   "status"
    t.integer  "amount"
    t.integer  "user_fee_amount"
    t.integer  "admin_fee_amount"
    t.string   "fullname"
    t.string   "email"
    t.string   "card_type"
    t.string   "card_last_four"
    t.string   "card_expiration_month"
    t.string   "card_expiration_year"
    t.integer  "campaign_id"
    t.datetime "created_at",            :null => false
    t.datetime "updated_at",            :null => false
    t.string   "address_one"
    t.string   "address_two"
    t.string   "city"
    t.string   "state"
    t.string   "postal_code"
    t.string   "country"
  end

  create_table "settings", :force => true do |t|
    t.string   "site_name"
    t.string   "facebook_app_id"
    t.string   "tweet_text"
    t.string   "google_id"
    t.datetime "created_at",                                     :null => false
    t.datetime "updated_at",                                     :null => false
    t.boolean  "initialized_flag",            :default => false, :null => false
    t.string   "logo_image_file_name"
    t.string   "logo_image_content_type"
    t.integer  "logo_image_file_size"
    t.datetime "logo_image_updated_at"
    t.string   "copyright_text"
    t.string   "facebook_title"
    t.text     "facebook_description"
    t.string   "facebook_image_file_name"
    t.string   "facebook_image_content_type"
    t.integer  "facebook_image_file_size"
    t.datetime "facebook_image_updated_at"
    t.text     "homepage_content"
    t.text     "custom_css"
    t.string   "ct_guest_user_id"
  end

  create_table "users", :force => true do |t|
    t.string   "email",                  :default => "",    :null => false
    t.string   "encrypted_password",     :default => "",    :null => false
    t.string   "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer  "sign_in_count",          :default => 0
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.string   "current_sign_in_ip"
    t.string   "last_sign_in_ip"
    t.datetime "created_at",                                :null => false
    t.datetime "updated_at",                                :null => false
    t.string   "fullname"
    t.string   "ct_user_id"
    t.boolean  "admin",                  :default => false
    t.boolean  "has_default_bank",       :default => false, :null => false
  end

  add_index "users", ["email"], :name => "index_users_on_email", :unique => true
  add_index "users", ["reset_password_token"], :name => "index_users_on_reset_password_token", :unique => true

end
