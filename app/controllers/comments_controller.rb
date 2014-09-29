class CommentsController < ApplicationController

  def new
    render status: :not_found unless params[:tipp_id]

    @tipp = Tipp.find_by(name: params[:tipp_id])
    @comment = Comment.new
  end

  def create
    return render status: :not_found unless comment_params[:tipp_id]

    @comment = Comment.new(comment_params)
    @tipp = Tipp.find(@comment.tipp_id)
    user = User.find(@comment.user_id)
    tipp_owner = User.find(@tipp.user_id)

    if @comment.save
      update_after_save(@tipp, user, tipp_owner)
      redirect_to new_tipp_path, flash: { notice: 'Thanks for your Comment!'}
    else
      error_message_for_length
      render  new_comment_path, tipp: @tipp.name
    end
  end

  private

  def error_message_for_length
    flash.now[:error] = 'Please make sure that your comment is in between 4 and 140 characters'
  end

  def update_after_save(tipp, user, owner)
    tipp.update_points('commented', user.role)
    user.update_status('commented')
    owner.update_status('vouched_for')
  end

  def comment_params
    params.require(:comment).permit(:content, :user_id, :tipp_id)
  end
end
