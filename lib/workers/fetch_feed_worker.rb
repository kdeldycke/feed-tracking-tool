# Put your code that runs your task inside the do_work method it will be
# run automatically in a thread. You have access to all of your rails
# models.  You also get logger and results method inside of this class
# by default.
class FetchFeedWorker < BackgrounDRb::Worker::RailsBase

  def do_work(args)
    # This method is called in it's own new thread when you
    # call new worker. args is set to :args

    # TODO: Write here code that download feed, parse them and cache them in local database.

    logger.info "Fetch the feeds !"

    # Commit suicide
    self.delete
  end

end
FetchFeedWorker.register
