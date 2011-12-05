require 'spec_helper'

describe VendorKit::Download do

  it { should belong_to(:version) }

  it { should validate_presence_of(:version) }

end
