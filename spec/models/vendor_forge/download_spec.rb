require 'spec_helper'

describe VendorForge::Download do

  it { should belong_to(:vendor) }
  it { should belong_to(:version) }

end