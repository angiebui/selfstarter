require 'spec_helper'

describe User do

  it { should have_many :orders }
  it { should respond_to :email }

end