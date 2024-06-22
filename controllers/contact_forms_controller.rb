class ContactFormsController < ApplicationController

  layout 'home'

  # GET /contact_forms/new
  # GET /contact_forms/new.xml
  def new
    @contact_form = ContactForm.new

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @contact_form }
    end
  end


  # POST /contact_forms
  # POST /contact_forms.xml
  def create
    # Remove invalid UTF8 characters that some spammers use.
    params[:utf8] = params[:utf8].encode('UTF-16le', :invalid => :replace, :replace => '').encode('UTF-8')
    params[:contact_form][:message] = params[:contact_form][:message].encode('UTF-16le', :invalid => :replace, :replace => '').encode('UTF-8')
    params[:contact_form][:email] = params[:contact_form][:email].encode('UTF-16le', :invalid => :replace, :replace => '').encode('UTF-8')
    params[:contact_form][:name] = params[:contact_form][:name].encode('UTF-16le', :invalid => :replace, :replace => '').encode('UTF-8')

    @contact_form = ContactForm.new(params[:contact_form])
    if not current_user
      params[:contact_form][:humanizer_answer] = params[:contact_form][:humanizer_answer].encode('UTF-16le', :invalid => :replace, :replace => '').encode('UTF-8')
      params[:contact_form][:humanizer_question_id] = params[:contact_form][:humanizer_question_id].encode('UTF-16le', :invalid => :replace, :replace => '').encode('UTF-8')

      @contact_form.humanizer_question_id = params[:humanizer_question_id] || params[:contact_form][:humanizer_question_id]
      @contact_form.humanizer_answer = params[:humanizer_answer] || params[:contact_form][:humanizer_answer]
    else
      @contact_form.bypass_humanizer = true
    end
    @contact_form.errors[:message] = "wrong answer"

    respond_to do |format|
      if @contact_form.save
        format.html { redirect_to(:back, :notice => 'Thank you for your feedback.') }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @contact_form.errors, :status => :unprocessable_entity }
      end
    end
  end

end
