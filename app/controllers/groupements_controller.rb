class GroupementsController < ApplicationController
  before_action :set_groupement, only: [:show, :edit, :update, :destroy]
  skip_before_action :verify_authenticity_token, only: [:destroy]
  add_breadcrumb "Fichiers", :parametre_index_path

  layout 'views/index'
  # GET /groupements
  # GET /groupements.json
  def index
    @groupements = Groupement.order(name: :asc)
    add_breadcrumb "groupements régionaux", :groupements_path
  end

  # GET /groupements/1
  # GET /groupements/1.json
  def show
    add_breadcrumb "groupements régionaux", :groupements_path
    add_breadcrumb 'detail', groupement_path
  end

  # GET /groupements/new
  def new
    @groupement = Groupement.new
    add_breadcrumb "groupements régionaux", :groupements_path
    add_breadcrumb 'nouveau GRVPC', :new_groupement_path
  end

  # GET /groupements/1/edit
  def edit
    add_breadcrumb "groupements régionaux", :groupements_path
    add_breadcrumb 'editer', :new_groupement_path
  end

  # POST /groupements
  # POST /groupements.json
  def create
    @groupement = Groupement.new(groupement_params)

    respond_to do |format|
      if @groupement.save
        format.html { redirect_to groupements_path, notice: 'Groupement was successfully created.' }
        format.json { render :show, status: :created, location: @groupement }
      else
        format.html { render :new }
        format.json { render json: @groupement.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /groupements/1
  # PATCH/PUT /groupements/1.json
  def update
    respond_to do |format|
      if @groupement.update(groupement_params)
        format.html { redirect_to @groupement, notice: 'Groupement was successfully updated.' }
        format.json { render :show, status: :ok, location: @groupement }
      else
        format.html { render :edit }
        format.json { render json: @groupement.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /groupements/1
  # DELETE /groupements/1.json
  def destroy
    @groupement.destroy
    respond_to do |format|
      format.html { redirect_to groupements_url, notice: 'Groupement was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_groupement
      @groupement = Groupement.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def groupement_params
      params.require(:groupement).permit(:name, :phone, :region_id, :localisation, :email)
    end
end
