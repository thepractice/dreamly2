class StaticPagesController < ApplicationController
  def home
  end

  def help
  end

  def about
  end

  def contact
  end

  def graph
  end

  def search
    @searchitems = PgSearch.multisearch(params[:query])
    @dreams = []
    @dream_items = @searchitems.where(searchable_type: "Dream")

    if params[:impression].present?   
      @dream_items.each do |dream_item|
        if Dream.find(dream_item.searchable_id).private == false    # If dream is public, include it in search
          if Dream.find(dream_item.searchable_id).impression >= params[:impression].to_f
            @dreams.push(Dream.find(dream_item.searchable_id))
          end
        end
      end
    else
      @dream_items.each do |dream_item|
        if Dream.find(dream_item.searchable_id).private == false    # If dream is public, include it in search
          @dreams.push(Dream.find(dream_item.searchable_id))
        end
      end
    end

    @dreams_raw = @dreams

    @users = []
    @user_items = @searchitems.where(searchable_type: "User")
    @user_items.each do |user_item|
      @users.push(User.find(user_item.searchable_id))
    end

  # Graph logic

    @word_count = Hash.new
    # Create hash of word frequencies in all relevant dreams
    @dreams_raw.each do |dream|
      dream.word_freq.each do |word_id, frequency|
        if @word_count[word_id] == nil
          @word_count[word_id] = { freq: frequency, dream_ids: [dream.id] }
        else
          @word_count[word_id][:freq] += frequency
          @word_count[word_id][:dream_ids].push(dream.id)
        end
      end
    end
    # Create hash with key = word_id, and v = freq, to be sortable
    @word_count_sort = Hash.new(0)
    @word_count.each do |k, v|
      @word_count_sort[k] = v[:freq]
    end
    
    @word_count_sort = @word_count_sort.sort_by { |k, v| v }
    @word_count_sort.reverse!

    if params[:graph]
      @min_words_constant = 15
      @min_assocs_constant = 2
    else
      @min_words_constant = 5
      @min_assocs_constant = 2
    end  

    @nodes = Array.new
    @min_words = [@word_count.length, @min_words_constant].min
    @min_words.times do |n|
      @nodes.push(@word_count_sort[n][0])     #@word_count_sort has become an array.
    end

    @links = Array.new

    @min_words.times do |n|
      @word_object_id = @nodes[n]
      @word_object_assocs = Hash.new(0)
      @word_object_dreams = @word_count[@word_object_id][:dream_ids]

      @word_object_dreams.each do |dream_id|
        Dream.find(dream_id).word_freq.each do |word_id, freq|
          if word_id != @word_object_id
            @word_object_assocs[word_id] += freq
          end
        end
      end

      @word_object_assocs = Hash[@word_object_assocs.sort_by{|k, v| v}.reverse]
      @min_assocs = [@word_object_assocs.length, @min_assocs_constant].min
      @min_assocs.times do |i|
        if @nodes.include? @word_object_assocs.keys[i]    # if the association is already a node
          @links.push([@nodes.index(@word_object_id), @nodes.index(@word_object_assocs.keys[i])]) # write the link
        else @nodes.include? @word_object_assocs.keys[i]    
          @nodes.push(@word_object_assocs.keys[i])
          @links.push([@nodes.index(@word_object_id), @nodes.index(@word_object_assocs.keys[i])])
        end
      end
    end


    @node_text = "["
    @nodes.each do |word_id|

      @node_text += "{\"name\":\"#{Word.find(word_id).name}\",\"value\":#{@word_count[word_id][:freq]}},"
    end
    @node_text = @node_text[0..-2] unless @nodes.empty?       # remove extra comma

    @node_text += "]"

    @link_text = "["
    @links.each do |link|
      @link_text += "{\"source\":#{link[0]},\"target\":#{link[1]}},"
    end

    @link_text = @link_text[0..-2] unless @links.empty?   # remove extra comma

    @link_text += "]"

    @graph_text = "{\"nodes\":#{@node_text},\"links\":#{@link_text}}"    

  end

end
