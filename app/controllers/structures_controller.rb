class StructuresController < ApplicationController
  before_action :set_structure, only: [:show, :edit, :update, :destroy]
  skip_before_action :verify_authenticity_token, only: [:destroy]
  add_breadcrumb "Acceuil", :parametre_index_path
  add_breadcrumb "gestion des partenaires", :structures_path
  layout 'views/index'
  # GET /structures
  # GET /structures.json
  def index
    @structures = Structure.all
    add_breadcrumb 'partenaires', structures_path
  end

  # GET /structures/1
  # GET /structures/1.json
  def show
    add_breadcrumb 'details', structure_path
  end

  # GET /structures/new
  def new
    @structure = Structure.new
    add_breadcrumb 'nouveau partenaire', new_structure_path
  end

  # GET /structures/1/edit
  def edit
    add_breadcrumb 'edition', structure_path
  end

  # GET /structures/1/accounts
  def accounts
    id = params[:id]
    @account = Member.where(structure_id: id)
  end

  # GET /structures/1/accounts/new
  # developer: mailto:mvondoyannick@gmail.com
  # detail:
  def new_account
    member = Member.new(account_params)
    if member.save
      redirect_to structures_path
    else
      puts 'Une erreur est survenue'
      puts member.errors.messages
    end
  end

  # POST /structures
  # POST /structures.json
  def create
    @structure = Structure.new(structure_params)

    respond_to do |format|
      if @structure.save
        format.html { redirect_to structures_path, notice: 'Structure was successfully created.' }
        format.json { render :show, status: :created, location: @structure }
      else
        format.html { render :new }
        format.json { render json: @structure.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /structures/1
  # PATCH/PUT /structures/1.json
  def update
    respond_to do |format|
      if @structure.update(structure_params)
        format.html { redirect_to @structure, notice: 'Structure a été correctement mise à jour.' }
        format.json { render :show, status: :ok, location: @structure }
      else
        format.html { render :edit }
        format.json { render json: @structure.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /structures/1
  # DELETE /structures/1.json
  def destroy
    @structure.destroy
    respond_to do |format|
      format.html { redirect_to structures_url, notice: 'Structure was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_structure
      @structure = Structure.find(params[:id])
    end

    def account_params
      params.permit(:structure, :phone, :prenom, :email, :password)
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def structure_params
      params.require(:structure).permit(:name, :raison, :contactname, :contantprenom, :contactphone, :contactemail, :region_id, :logo, :document, :email, :pwd, :rue, :bp, :phonestructure, :fonction, :category)
    end
end
