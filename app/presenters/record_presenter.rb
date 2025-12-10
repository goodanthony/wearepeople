# app/presenters/record_presenter.rb
class RecordPresenter < ApplicationPresenter
  delegate :id, :created_at, :updated_at, to: :record

  private

    def created_at_iso
      created_at&.iso8601
    end

    def updated_at_iso
      updated_at&.iso8601
    end
end
