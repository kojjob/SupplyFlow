module PaginationHelper
  def simple_pagination(total_count, per_page = 25, current_page = 0)
    current_page = current_page.to_i
    total_pages = (total_count.to_f / per_page).ceil
    
    return if total_pages <= 1
    
    content_tag :div, class: "flex items-center justify-between border-t border-gray-200 dark:border-gray-700 bg-white dark:bg-gray-800 px-4 py-3 sm:px-6" do
      concat(
        content_tag(:div, class: "flex flex-1 justify-between sm:hidden") do
          if current_page > 0
            concat link_to "Previous", url_for(page: current_page - 1), class: "relative inline-flex items-center rounded-md border border-gray-300 dark:border-gray-600 bg-white dark:bg-gray-700 px-4 py-2 text-sm font-medium text-gray-700 dark:text-gray-200 hover:bg-gray-50 dark:hover:bg-gray-600"
          else
            concat content_tag(:span, "Previous", class: "relative inline-flex items-center rounded-md border border-gray-300 dark:border-gray-600 bg-gray-100 dark:bg-gray-800 px-4 py-2 text-sm font-medium text-gray-500 dark:text-gray-400 cursor-not-allowed")
          end
          
          if current_page < total_pages - 1
            concat link_to "Next", url_for(page: current_page + 1), class: "relative ml-3 inline-flex items-center rounded-md border border-gray-300 dark:border-gray-600 bg-white dark:bg-gray-700 px-4 py-2 text-sm font-medium text-gray-700 dark:text-gray-200 hover:bg-gray-50 dark:hover:bg-gray-600"
          else
            concat content_tag(:span, "Next", class: "relative ml-3 inline-flex items-center rounded-md border border-gray-300 dark:border-gray-600 bg-gray-100 dark:bg-gray-800 px-4 py-2 text-sm font-medium text-gray-500 dark:text-gray-400 cursor-not-allowed")
          end
        end
      )
      
      concat(
        content_tag(:div, class: "hidden sm:flex sm:flex-1 sm:items-center sm:justify-between") do
          concat(
            content_tag(:div) do
              concat content_tag(:p, class: "text-sm text-gray-700 dark:text-gray-300") do
                concat "Showing "
                concat content_tag(:span, class: "font-medium") { ((current_page * per_page) + 1).to_s }
                concat " to "
                concat content_tag(:span, class: "font-medium") { [(current_page + 1) * per_page, total_count].min.to_s }
                concat " of "
                concat content_tag(:span, class: "font-medium") { total_count.to_s }
                concat " results"
              end
            end
          )
          
          concat(
            content_tag(:div) do
              content_tag(:nav, class: "isolate inline-flex -space-x-px rounded-md shadow-sm", "aria-label" => "Pagination") do
                # Previous page
                if current_page > 0
                  concat link_to url_for(page: current_page - 1), class: "relative inline-flex items-center rounded-l-md px-2 py-2 text-gray-400 dark:text-gray-500 ring-1 ring-inset ring-gray-300 dark:ring-gray-600 hover:bg-gray-50 dark:hover:bg-gray-700 focus:z-20 focus:outline-offset-0" do
                    concat content_tag(:span, "Previous page", class: "sr-only")
                    concat content_tag(:i, nil, class: "fas fa-chevron-left h-5 w-5")
                  end
                else
                  concat content_tag(:span, class: "relative inline-flex items-center rounded-l-md px-2 py-2 text-gray-300 dark:text-gray-600 ring-1 ring-inset ring-gray-300 dark:ring-gray-600 cursor-not-allowed") do
                    concat content_tag(:span, "Previous page", class: "sr-only")
                    concat content_tag(:i, nil, class: "fas fa-chevron-left h-5 w-5")
                  end
                end
                
                # Page numbers
                visible_pages = 5
                start_page = [0, current_page - (visible_pages / 2)].max
                end_page = [start_page + visible_pages - 1, total_pages - 1].min
                
                # Adjust start page if we're at the end
                if end_page - start_page < visible_pages - 1
                  start_page = [0, end_page - visible_pages + 1].max
                end
                
                (start_page..end_page).each do |page|
                  if page == current_page
                    concat content_tag(:span, class: "relative z-10 inline-flex items-center bg-blue-600 px-4 py-2 text-sm font-semibold text-white focus:z-20 focus-visible:outline focus-visible:outline-2 focus-visible:outline-offset-2 focus-visible:outline-indigo-600") do
                      (page + 1).to_s
                    end
                  else
                    concat link_to (page + 1).to_s, url_for(page: page), class: "relative inline-flex items-center px-4 py-2 text-sm font-semibold text-gray-900 dark:text-gray-200 ring-1 ring-inset ring-gray-300 dark:ring-gray-600 hover:bg-gray-50 dark:hover:bg-gray-700 focus:z-20 focus:outline-offset-0"
                  end
                end
                
                # Next page
                if current_page < total_pages - 1
                  concat link_to url_for(page: current_page + 1), class: "relative inline-flex items-center rounded-r-md px-2 py-2 text-gray-400 dark:text-gray-500 ring-1 ring-inset ring-gray-300 dark:ring-gray-600 hover:bg-gray-50 dark:hover:bg-gray-700 focus:z-20 focus:outline-offset-0" do
                    concat content_tag(:span, "Next page", class: "sr-only")
                    concat content_tag(:i, nil, class: "fas fa-chevron-right h-5 w-5")
                  end
                else
                  concat content_tag(:span, class: "relative inline-flex items-center rounded-r-md px-2 py-2 text-gray-300 dark:text-gray-600 ring-1 ring-inset ring-gray-300 dark:ring-gray-600 cursor-not-allowed") do
                    concat content_tag(:span, "Next page", class: "sr-only")
                    concat content_tag(:i, nil, class: "fas fa-chevron-right h-5 w-5")
                  end
                end
              end
            end
          )
        end
      )
    end
  end
end