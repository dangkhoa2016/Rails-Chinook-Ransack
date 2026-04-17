class ApplicationPolicy
  attr_reader :user, :record

  def initialize(user, record)
    @user = user
    @record = record
  end

  # Admin có toàn quyền, user thường chỉ được xem
  def index?    = true
  def show?     = true
  def new?      = user.admin?
  def create?   = user.admin?
  def edit?     = user.admin?
  def update?   = user.admin?
  def destroy?  = user.admin?

  # JSON select endpoints — tất cả user đều dùng được (cho form dropdowns)
  def json_list_for_select_element? = true

  class Scope
    def initialize(user, scope)
      @user = user
      @scope = scope
    end

    def resolve
      @scope.all
    end

    private

    attr_reader :user, :scope
  end
end
