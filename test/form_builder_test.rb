require 'test_helper'

# `raise output_buffer.inspect` if you want to peek inside generated html
class FormBuilderTest < ActionView::TestCase
  
  # -- Form -----------------------------------------------------------------
  def test_form
    with_formatted_form_for(@user, :url => ''){|f|}
    assert_select "form[class='formatted']"
  end
  
  def test_form_with_type_inline
    with_formatted_form_for(@user, :url => '', :type => :inline){|f|}
    assert_select "form[class='formatted form-inline']"
  end
    
  def test_form_with_type_horizontal
    with_formatted_form_for(@user, :url => '', :type => :horizontal){|f|}
    assert_select "form[class='formatted form-horizontal']"
  end
  
  def test_form_with_type_search
    with_formatted_form_for(@user, :url => '', :type => :search){|f|}
    assert_select "form[class='formatted form-search']"
  end
  
  def test_form_overriding_existing_class
    with_formatted_form_for(@user, :url => '', :type => :inline, :html => {:class => 'custom'}){|f|}
    assert_select "form[class='custom form-inline']"
  end
  
  def test_form_with_type_derived_from_class
    with_formatted_form_for(@user, :url => '', :type => :inline, :html => {:class => 'form-horizontal'}){|f|}
    assert_select "form[class='form-horizontal']"
  end
  
  # -- Text Field -----------------------------------------------------------
  def test_text_field
    with_text_field :name
    assert_select "div[class='control-group']" do
      assert_select "label[for='user_name']", 'Name'
      assert_select "div[class='controls']" do
        assert_select "input[type='text'][id='user_name'][name='user[name]']"
      end
    end
  end
  
  def test_text_field_prepend_append
    with_text_field :twitter, :prepend => '@', :append => '!'
    assert_select "div[class='control-group']" do
      assert_select "label[for='user_twitter']", 'Twitter'
      assert_select "div[class='controls']" do
        assert_select "div[class='input-prepend input-append']" do
          assert_select "span[class='add-on']", '@'
          assert_select "input[type='text'][id='user_twitter'][name='user[twitter]']"
          assert_select "span[class='add-on']", '!'
        end
      end
    end
  end
  
  def test_text_field_prepend_append_html
    with_text_field :twitter, :prepend_html => '<b>b</b>', :append_html => '<i>i</i>'
    assert_select "div[class='control-group']" do
      assert_select "label[for='user_twitter']", 'Twitter'
      assert_select "div[class='controls']" do
        assert_select "div[class='input-prepend input-append']" do
          assert_select "i", 'i'
          assert_select "input[type='text'][id='user_twitter'][name='user[twitter]']"
          assert_select "b", 'b'
        end
      end
    end
  end
  
  def test_text_field_with_help_block
    with_text_field :name, :help_block => 'Help'
    assert_select "div[class='control-group']" do
      assert_select "div[class='controls']" do
        assert_select "input[type='text'][id='user_name'][name='user[name]']"
        assert_select "span[class='help-block']", 'Help'
      end
    end
  end
  
  def test_text_field_with_help_inline
    with_text_field :name, :help_inline => 'Help'
    assert_select "div[class='control-group']" do
      assert_select "div[class='controls']" do
        assert_select "input[type='text'][id='user_name'][name='user[name]']"
        assert_select "span[class='help-inline']", 'Help'
      end
    end
  end
  
  def test_text_field_with_errors
    assert @user.invalid?
    with_text_field :name
    assert_select "div[class='control-group error']" do
      assert_select "div[class='controls']" do
        assert_select "input[type='text'][id='user_name'][name='user[name]']"
        assert_select "span[class='help-block']", "can&#39;t be blank"
      end
    end
  end
  
  def test_text_field_with_blank_label
    with_text_field :name, :label => ''
    assert_select "label[for='user_name']", 0
    
    with_text_field :name, :label => false
    assert_select "label[for='user_name']", 0
  end
  
  def test_text_field_for_inline_form
    with_formatted_form_for(@user, :url => '', :type => :inline){|f| f.text_field :name }
    assert_select "div[class='control-group']", 0
    assert_select "input[type='text'][id='user_name'][name='user[name]']"
  end
  
  def test_text_field_with_no_builder
    with_text_field :name, :builder => false
    assert_select "div[class='control-group']", 0
    assert_select "label[for='user_name']", 0
    assert_select "input[builder='false']", 0
  end
  
  # -- Radio Button ---------------------------------------------------------
  def test_radio_button
    with_radio_button :role, ['admin', 'regular']
    assert_select "div[class='control-group']" do
      assert_select "div[class='control-label']", 'Role'
      assert_select "div[class='controls']" do
        assert_select "label" do
          assert_select "input[type='radio'][id='user_role_admin'][name='user[role]'][value='admin']"
        end
        assert_select "label" do
          assert_select "input[type='radio'][id='user_role_regular'][name='user[role]'][value='regular']"
        end
      end
    end
  end
  
  def test_radio_button_with_custom_label
    with_radio_button :role, ['admin', 'regular'], :label => 'Access'
    assert_select "div[class='control-label']", 'Access'
  end
  
  def test_radio_button_with_choices_tuples
    with_radio_button :role, [['Admin', 1], ['Regular', 2]]
    assert_select "label[class='radio']", 'Admin' do
      assert_select "input[type='radio'][id='user_role_1'][name='user[role]'][value='1']"
    end
    assert_select "label[class='radio']", 'Regular' do
      assert_select "input[type='radio'][id='user_role_2'][name='user[role]'][value='2']"
    end
  end
  
  def test_radio_button_inline
    with_radio_button :role, ['admin', 'regular'], :inline => true
    assert_select "label[class='radio inline']", 'admin' do
      assert_select "input[type='radio'][id='user_role_admin'][name='user[role]'][value='admin']"
    end
  end
  
  # -- Check Boxes ----------------------------------------------------------
  def test_check_box
    with_check_box :colors, {}, 'yes', 'no'
    assert_select "div[class='control-group']" do
      assert_select "div[class='controls']" do
        assert_select "input[type='hidden'][name='user[colors]'][value='no']"
        assert_select "label[class='checkbox']" do
          assert_select "input[type='checkbox'][id='user_colors'][name='user[colors]'][value='yes']"
        end
      end
    end
  end
  
  def test_check_box_custom_label
    with_check_box :colors, :label => 'Kolors'
    assert_select "label", 'Kolors'
  end
  
  def test_check_box_with_choices_array
    with_check_box :colors, {}, ['red', 'green']
    assert_select "div[class='controls']" do
      assert_select "label[class='checkbox']", 'red' do
        assert_select "input[type='checkbox'][id='user_colors_red'][name='user[colors][]'][value='red']"
      end
      assert_select "label[class='checkbox']", 'green' do
        assert_select "input[type='checkbox'][id='user_colors_green'][name='user[colors][]'][value='green']"
      end
    end
  end
  
  def test_check_box_with_choices_and_labels
    with_check_box :colors, {}, [['Red', 'r'], ['Green', 'g']]
    assert_select "div[class='controls']" do
      assert_select "label[class='checkbox']", 'Red' do
        assert_select "input[type='checkbox'][id='user_colors_r'][name='user[colors][]'][value='r']"
      end
      assert_select "label[class='checkbox']", 'Green' do
        assert_select "input[type='checkbox'][id='user_colors_g'][name='user[colors][]'][value='g']"
      end
    end
  end
  
  def test_check_box_inline
    with_check_box :colors, {:inline => true}, ['red', 'green']
    assert_select "label[class='checkbox inline']" do
      assert_select "input[type='checkbox'][id='user_colors_red'][name='user[colors][]']"
    end
  end
  
  def test_check_box_with_no_builder
    with_check_box :colors, :builder => false
    assert_select "div[class='control-group cg-colors']", 0
    assert_select "label[for='user_colors']", 0
    assert_select "input[builder='false']", 0
  end
  
  # -- Element --------------------------------------------------------------
  def test_element
    with_element 'Label', 'Content'
    assert_select "div[class='control-group']" do
      assert_select "label[class='control-label']", 'Label'
      assert_select "div[class='controls']", 'Content'
    end
  end
  
  def test_element_with_block
    with_element 'Label' do
      'Content'
    end
    assert_select "div[class='control-group']" do
      assert_select "label[class='control-label']", 'Label'
      assert_select "div[class='controls']", 'Content'
    end
  end
  
  def test_element_with_no_label
    with_element do
      'Content'
    end
    assert_select "label[class='control-label']", 0
    assert_select "div[class='controls']", 'Content'
  end
  
  # -- Submit ---------------------------------------------------------------
  def test_submit
    with_submit
    assert_select "input[name=commit][value='Create User']"
  end
  
  def test_submit_with_label
    with_submit 'Create'
    assert_select "input[name='commit'][value='Create']"
  end
  
  # -- Others ---------------------------------------------------------------
  def test_select_field
    with_select :name, ['Bob']
    assert_select "div[class='controls']" do
      assert_select "select[id='user_name'][name='user[name]']" do
        assert_select "option[value='Bob']", 'Bob'
      end
    end
  end
  
  def test_password_field
    with_password_field :name
    assert_select "div[class='controls']" do
      assert_select "input[type='password'][id='user_name'][name='user[name]']"
    end
  end
  
  def test_email_field
    with_email_field :name
    assert_select "div[class='controls']" do
      assert_select "input[type='email'][id='user_name'][name='user[name]']"
    end
  end
  
  def test_telephone_field
    with_telephone_field :name
    assert_select "div[class='controls']" do
      assert_select "input[type='tel'][id='user_name'][name='user[name]']"
    end
  end
  
  def test_number_field
    with_number_field :name
    assert_select "div[class='controls']" do
      assert_select "input[type='number'][id='user_name'][name='user[name]']"
    end
  end
  
  def test_text_area
    with_text_area :name
    assert_select "div[class='controls']" do
      assert_select "textarea[id='user_name'][name='user[name]']"
    end
  end
  
  def test_file_field
    with_file_field :name
    assert_select "div[class='controls']" do
      assert_select "input[type='file'][id='user_name'][name='user[name]']"
    end
  end
  
  def test_range_field
    with_range_field :name
    assert_select "div[class='controls']" do
      assert_select "input[type='range'][id='user_name'][name='user[name]']"
    end
  end
  
  def test_search_field
    with_search_field :name
    assert_select "div[class='controls']" do
      assert_select "input[type='search'][id='user_name'][name='user[name]']"
    end
  end
  
  def test_datetime_select
    with_datetime_select :timestamp
    assert_select "div[class='controls']" do
      assert_select "select[id='user_timestamp_1i'][name='user[timestamp(1i)]']"
      assert_select "select[id='user_timestamp_2i'][name='user[timestamp(2i)]']"
      assert_select "select[id='user_timestamp_3i'][name='user[timestamp(3i)]']"
      assert_select "select[id='user_timestamp_4i'][name='user[timestamp(4i)]']"
      assert_select "select[id='user_timestamp_5i'][name='user[timestamp(5i)]']"
    end
  end
  
  def test_date_select
    with_date_select :timestamp
    assert_select "div[class='controls']" do
      assert_select "select[id='user_timestamp_1i'][name='user[timestamp(1i)]']"
      assert_select "select[id='user_timestamp_2i'][name='user[timestamp(2i)]']"
      assert_select "select[id='user_timestamp_3i'][name='user[timestamp(3i)]']"
    end
  end
  
  def test_time_select
    with_time_select :timestamp
    assert_select "div[class='controls']" do
      assert_select "input[type='hidden'][id='user_timestamp_1i'][name='user[timestamp(1i)]']"
      assert_select "input[type='hidden'][id='user_timestamp_2i'][name='user[timestamp(2i)]']"
      assert_select "input[type='hidden'][id='user_timestamp_3i'][name='user[timestamp(3i)]']"
      assert_select "select[id='user_timestamp_4i'][name='user[timestamp(4i)]']"
      assert_select "select[id='user_timestamp_5i'][name='user[timestamp(5i)]']"
    end
  end
  
  def test_time_zone_select
    with_time_zone_select :timestamp
    assert_select "div[class='controls']" do
      assert_select "select[id='user_timestamp'][name='user[timestamp]']"
    end
  end

  def test_url_field
    with_url_field :url
    assert_select "div[class='controls']" do
      assert_select "input[type='url'][id='user_url'][name='user[url]']"
    end
  end

  # -- Required Mark on Label -----------------------------------------------

  def test_config_prepend_required_mark_method
    assert_respond_to FormattedForm, :prepend_required_mark=
  end

  def test_prepend_required_mark_with_defaults
    FormattedForm.prepend_required_mark = true
    with_formatted_form_for(@user, :url => ''){ |f| f.text_field :name }
    assert_select "span[class='control-label-required-mark']", '*'
    FormattedForm.prepend_required_mark = nil
  end

  def test_prepend_required_mark_set_to_string
    FormattedForm.prepend_required_mark = '8'
    with_formatted_form_for(@user, :url => ''){ |f| f.text_field :name }
    assert_select "span[class='control-label-required-mark']", '8'
    FormattedForm.prepend_required_mark = nil
  end

  def test_prepend_required_mark_set_to_hash
    FormattedForm.prepend_required_mark = {tag: :div, text: '(R)', css_class: 'this-is-required'}
    with_formatted_form_for(@user, :url => ''){ |f| f.text_field :name }
    assert_select "div[class='this-is-required']", '(R)'
    FormattedForm.prepend_required_mark = nil
  end

  def test_prepend_required_mark_on_required_attribute
    FormattedForm.prepend_required_mark = true
    with_formatted_form_for(@user, :url => '') { |f| f.text_field :twitter, required: true }
    assert_select "span[class='control-label-required-mark']", '*'
  end

  def test_prepend_required_mark_on_prepend_required_attribute_with_defaults
    with_formatted_form_for(@user, :url => ''){ |f| f.text_field :name, prepend_required_mark: true }
    assert_select "span[class='control-label-required-mark']", '*'
  end

  def test_prepend_required_mark_on_prepend_required_attribute_set_to_string
    with_formatted_form_for(@user, :url => ''){ |f| f.text_field :name, prepend_required_mark: '8' }
    assert_select "span[class='control-label-required-mark']", '8'
  end

  def test_prepend_required_mark_on_prepend_required_attribute_set_to_hash
    with_formatted_form_for(@user, :url => ''){ |f| f.text_field :name, prepend_required_mark: {tag: :div, text: '(R)', css_class: 'this-is-required'} }
    assert_select "div[class='this-is-required']", '(R)'
  end
end
