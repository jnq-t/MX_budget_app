require "test_helper"

class MemberTest < ActiveSupport::TestCase
  def setup 
    @member = Member.new(guid: "MBR-12345678-1234-1234-1234-1234567890ab", 
                         user_guid: "USR-12345678-1234-1234-1234-1234567890ab",
                         institution_code: "mxbank")
  end

  test "should be valid" do 
    assert @member.valid? 
  end


  test "should have guid" do
    @member.guid = " " 
    assert_not @member.valid? 
  end

  test "should have valid user_guid" do
    @member.user_guid = " "
    assert_not @member.valid?
  end

  test "invalid guids should be invalid" do 
    invalid_guids = %w[MBR-1234-12345678-1234-1234567890ab-1234 MRB-12345678-1234-1234-1234-1234567890ab
                      MBR;12345678,1234.1234-1234!1234567890ab]
    invalid_guids.each do |invalid_guid|
      @member.guid = invalid_guid
      assert_not @member.valid?, "#{invalid_guid.inspect} should be invalid"
    end
  end
end
