# Base presenter for ActiveRecord-style models.
#
# Adds common delegates and helpers for `id` and timestamp fields, so
# resource presenters can stay focused on shaping the JSON and permission logic.
#
# Usage:
#   class InspectionPresenter < RecordPresenter
#     def attributes
#       {
#         id:         id,
#         status:     record.status,
#         created_at: created_at_iso
#       }
#     end
#   end
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
