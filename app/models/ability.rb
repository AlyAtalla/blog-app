class Ability
  include CanCan::Ability

  def initialize(user)
    can :read, Post # start by defining rules for all users, also not logged ones
    return unless user.present?

    # if the user is logged in can create posts, comments, and likes
    can :create, Post
    can :create, Comment
    can :create, Like

    can :destroy, Post, author_id: user.id # if the user is logged in can delete its own posts
    can :destroy, Comment, user_id: user.id # if the user is logged in can delete its own comments
    can :destroy, Like, user_id: user.id # if the user is logged in can delete its own likes

    if user.admin?
      can :manage, :all # give all remaining permissions only to the admins
    end
  end
end
