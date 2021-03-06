class AccessController < ApplicationController
  #on verifie si l'utilisateur est connecter avant de donner acces aux ressource
  #before_action :confirm_logged_in, only: [:login, :attemp_login, :admin, :logout]
  skip_before_action :verify_authenticity_token, only: [:admin_new]
  before_action :authenticate_admin!, except: [:login, :serviceShow]

  add_breadcrumb "Fichiers", :parametre_index_path
  #add_breadcrumb "découpage administratif", :parametre_localisation_path
  HTTParty::Basement.default_options.update(verify: false)


  def index
  end

  def new
    @request = Fylo.new
    render layout: 'views/index'
  end

  def login
    #render layout: 'login'
    # vue de connexion principale
    render layout: 'template/login2'
  end

  def login2
  render layout: 'template/login2'
  end

  #les services de la plateforme
  def serviceShow
    render layout: 'template/login2'
  end
  # fin des services

  #pour la lecture des email 
  def email
    render layout: 'wemail'
    
  end

  #Administration de la plateforme
  #route /acces/admin
  #params:
  def admin
    @top_infraction = Convocation.distinct.pluck(:infraction_id)
    @top_alerte = Alerte.distinct.pluck(:type_id)
    #render layout: 'fylo'
    #render layout: 'admin'
    render layout: 'views/index'
  end


  #apropos
  #route /access/request/about
  #params
  def about
    
  end
  #Documentation de la plateforme
  #route /acces/request/docs
  #params
  def request_doc
    
  end

  #permet une administration totale
  def access_control
    
  end
  

  #Demander un compte à la DGSN
  #route /access/request/account
  #params:
  def request_account
    @request = Fylo.new(params[:name])

    respond_to do |format|
      if @request.save
        format.html { redirect_to @request, notice: 'Alerte was successfully created.' }
        format.json { render :show, status: :created, location: @request }
      else
        format.html { render controller: "access", action: "login" }
        format.json { render json: @request.errors, status: :unprocessable_entity }
      end
    end
  end

  def request_service
    @alert = Alerte.all
    render layout: 'other'

  end

  def attemp_account
    if params[:service].present? && params[:nom].present? && params[:prenom].present? && params[:matricule].present? && params[:phone].present? && params[:email].present? && params[:_pwd].present? && params[:pwd_confirme].present?
      #on considere que tout est ok
      redirect_to(action: 'login')
    else
      flash[:notice] = "Certains champs semblent etre vides"
      print "Certains champs semblent etre vides #{params}"
    end
  end

  #permet de generer un fichier PDF
  def read
    
  end

  #voir toutes les alertes
  def alerte_all
    @alerte = Alerte.all
    render layout: 'admin'
  end

  #voir toutes les convocations
  def convocation_all
    @convocation = Convocation.all
    #render layout: 'admin'
    render layout: 'views/index'
  end

  def attemp_login
    if params[:matricule].present? && params[:pwd].present?
      found_user = Fylo.where(matricule: params[:matricule]).first
      if found_user && found_user.password == params[:pwd]
        print "tout est ok"
        print "=============== utilisateur trouvé ============"
        session[:name] = found_user.name
        session[:id] = found_user.id
        session[:lastConnection] = found_user.lastConnected
        flash[:notice] = "#{session[:name]} vous etes connecté"
        case current_user.role.name #found_user.service
          when "urgence"
            session[:role] = "urgence"
            redirect_to(action: 'request_service', id: 'fylo')
          when "developer"
            session[:role] = "admin"
            redirect_to(action: 'developer')
          when "admin"
            session[:role] = current_user.role.name
            redirect_to(action: 'admin')
          when "superAdmin"
            session[:role] = current_user.role.name
            redirect_to "/access/admin"
          when "administrateur"
            session[:role] = current_user.role.name
            redirect_to access_a_l_administration_path
            #redirect_to action: administration
          when "camwater"
            session[:role] = current_user.role.name
            redirect_to(action: 'request_service') 
        end
      else
        print "======== utilisateur inconnu ========="
        flash[:notice] = "Impossible de vous identifier"
        redirect_to root_path
      end
    else
      flash[:notice] = "Une information semble etre incomplete"
      redirect_to root_path
    end
    
  end

  def logout
    session[:role] = nil
    print "======= #{session[:role].inspect} ========="
    redirect_to(action: 'login')
  end

  #=========== pour les partenaires ==============
  def partenaires
    #render layout: 'admin'
    render layout: 'views/index'
  end

  #pour le paiement dans l'administration camerounaise
  def administration
    #render layout: 'administration'
    render layout: 'views/index'
  end

  #pour la recherche des documents
  def search_document
    query = params[:input]
    type = params[:type]
    case type
      when "cni"
        @title = "Recherche suivant "+type
        @query = Convocation.where(cni: query).uniq
      when "immatriculation"
        @query = Convocation.where(immatriculation: query).uniq
      when "telephone"
        @title = "Recherche suivant "+type
        @query = Convocation.where(phone: query, status: "impaye").order(created_at: :desc).order(cni: :desc)
        #@cni = Convocation 
        #redirect_to action: self, id: "#{type}/#{query}"
      when "code"
        @query = Convocation.where(code: query).uniq
    end
    #render layout: 'administration'
    render layout: 'views/index'
  end

  def search_cni
    cni = params[:cni]
    @query = Convocation.where(cni: cni)
    #render layout: 'administration'
    render layout: 'views/index'
  end

  #lesture d'un document de contravention
  def read_document
    #puts "======= #{params[:controller]} ========"
    #on pars chercher le contenu du params
    @query = Convocation.find(params[:contravention_id])
    #render layout: 'administration'
    render layout: 'views/index'
  end

  #permet de payer une contravention
  def buy_document
    #confirm paiement

    #recherche de l'enregistrement dans la BD
    pay = Convocation.find(params[:id])

    #debut de la mise a jour
    pay.status = "paye"
    #s = pay.save
    #verification
    if pay.save
      puts "====== c'est bon, on a update ========"
      flash[:notice] = "A Paiement effectué"
      redirect_to action: "/access/a/l/administration"
    else
      puts "========= error ========="
      #redirect_to action: 'administration', notice: "Impossible d effectuer le paiement : #{s.errors.messages}"
    end
    #render layout: 'administration'
    render layout: 'views/index'
  end

  # Never trust parameters from the scary internet, only allow the white list through.
  # def access_params
  #   params.require(:fylo).permit(:name, :prenom, :email)
  # end
  #

  def attemp_buying

  end

  #gestion des partenaires
  def partner
    #render layout: 'fylo'
    render layout: 'views/index'
  end

  #detail sur les partenaires
  def partner_detail
    if params[:jeton] == 'grvpc'
      @query = Grvpc.find_by(id: params[:id])
    elsif params[:jeton] == 'metropolis'
      @query = Metropoli.find_by(id: params[:id])
    elsif params[:jeton] == 'member'
      @query = Member.find_by(id: params[:id])
    end
    #render layout: 'fylo'
    render layout: 'views/index'
  end

  #for test
  def open
    #render layout: 'fylo'
    render layout: 'views/index'
  end

  def application
    add_breadcrumb "modules", :access_application_path
    #render layout: 'fylo'
    render layout: 'views/index'
  end

  #pour les statistiques et les etats
  # @route: GET parametre/etat
  # @detail: vue pour les memu des etats
  # @developer: email:mvondoyannick@gmail.com
  def edition
    add_breadcrumb 'edition', :parametre_etat_path
    #render layout: 'fylo'
    render layout: 'views/index'
  end

  def systeme
    add_breadcrumb "paramètres", :access_systeme_path
    #render layout: 'fylo'
    render layout: 'views/index'
  end

  #pour les solutions de paiements sur la plateformes
  # @detail: retourne les solutions de paiements disponible sur la plateforme
  # @params: aucun
  # @route:
  # @developer: mailto:mvondoyannick@gmail.com
  def solution_paiement

    #add_breadcrumb "solutions menu", :access_sols_paiement
    #render layout: 'fylo'
    render layout: 'views/index'
  end

  #pour le type de paiement sur la plateforme
  # @detail: paiement direct/instatané ou paiement differé
  def type_paiement
    add_breadcrumb 'solution menu', :parametre_paiement_path
    add_breadcrumb 'parametres', :access_systeme_path
    add_breadcrumb 'modes de paiement', :parametre_type_paiement_path
    #render layout: 'fylo'
    render layout: 'views/index'
  end

  #supprimer un type de paiement en changeant le statut
  def delete_type_paiement
    data = params[:type_id]

    #recherche et suppression
    query = Modepaiement.find(data)
    query.status = 0
    if query.save
      redirect_to parametre_type_paiement_path
    end
  end

  #ajouter une type de mode de paiement
  def add_type_paiement
    data = params[:type_id]

    #recherche et suppression
    query = Modepaiement.find(data)
    query.status = 1
    if query.save
      redirect_to parametre_type_paiement_path
    end
  end


  #pour activer le type de mode de paiement selectionné
  def attempt_type
    #permet de faire la recherche
    content = params


  end

  #module de gestion des langues
  # @detail: retourne les langues disponible sur le systeme
  # @route:
  # @developer: mailto:mvondoyannick@gmail.com
  def lange
    @langue = Langue.new
    #render layout: 'fylo'
    render layout: 'views/index'
  end

  def paiement
    add_breadcrumb 'paramètre', access_systeme_path
    add_breadcrumb 'modes de paiement', parametre_paiement_path
    #render layout: 'fylo'
    render layout: 'views/index'
  end

  #importation des parametres
  def importation
    file = params[:file]
    Alerte.import(file)
    flash[:notice] = "Fichier #{file} importé avec succes"
    #render layout: 'fylo'
    render layout: 'views/index'
  end

  #exportation des documents
  def exportation
    #render layout: 'fylo'
    render layout: 'views/index'
  end

  def tested
    respond_to do |format|
      format.html do
        Alerte.all
        render layout: 'fylo'
      end
      format.xls
      format.csv {send_data Alerte.all.to_csv}
      format.xls
    end
  end

  #pour les parametres de la table selectionnée
  def export_detail
    puts params[:table]
    redirect_to controller: :access, action: "#{params[:table]}", data: params[:table]
  end

  def constat
    #render layout: 'fylo'
    render layout: 'views/index'
  end

  def convocation
    #render layout: 'fylo'
    render layout: 'views/index'
  end

  def alerte
    #render layout: 'fylo'
    render layout: 'views/index'
  end

  #configuration des inportation-exportation
  def setup_import_export
    #render layout: 'fylo'
    render layout: 'views/index'
  end

  #ajout des utilisateur administrateurs
  def admin_show
    @user = Admin.where(role_id: 1).order(name: :asc)
    add_breadcrumb 'utilisateurs', :parametre_admin_path
    add_breadcrumb 'administrateurs & décideurs', :parametre_admins_admin_show_path
    #render layout: 'fylo'
    render layout: 'views/index'
  end


  #pour effectuer les testes sur les vues admin LTE
  def test

    render layout: 'views/index'

  end

  # nouveau design
  def utilisateurs

  end

  def dashboard
    @active = 'active'
    render layout: 'views/index'
  end

  def dashboard1
    @active = 'active'
    render layout: 'views/index'
  end

  def users
    @admin = Admin.all
    render layout: 'views/index'
  end

  def alertes
    @alertes = Alerte.all

  end

  def parametres

  end

  def agents

  end

  def programmations

  end

  def contraventions

  end




  #bloquer un administrateur ou les decideurs
  # detail:
  # route: GET
  # developer: mailto:mvondoyannick@gmail.com
  def admin_lock
    data = params[:user_id]
    role = params[:role_id]

    #start query
    query = Admin.where(id: data, role_id: role)

    #on change le statut de l'utilisateur
    query.lock = true

    if query.save
      redirect_to parametre_admins_admin_show_path, flash[:notice] = "User locked"
    end

  end

  #permet d'afficher les decideurs de la plateforme
  def decideur_show
    @user = Admin.where(role_id: 2).order(name: :asc)
    add_breadcrumb 'utilisateur', parametre_admin_path
    add_breadcrumb 'decideurs', parametre_decideurs_path
    render layout: 'fylo'
  end


  #ajout despartenaires
  def member_show
    @user = Member.all
    render layout: 'fylo'
  end

  #enregistrement d'un nouveau partenaire
  def member_new
    @member = Member.new

    #retriving datas
    member = Member.new(email: params[:email], password: params[:password], matricule: SecureRandom.hex(10).upcase, service_id: params[:service_id], phone: params[:phone], region_id: params[:region_id])
    if member.save
      flash[:notice] = "Membre ajouter avec succes"
      redirect_to action: member_new
    else
      flash[:notice] = "Impossible d'enregistrer un partenaire: #{member.errors.messages}"
      puts "====== #{member.errors.messages} ======="
    end
    render layout: 'fylo'
  end

  def admin_new
    @data = Admin.new(admin_params)
    puts @data

    if @data.save
      #on envoi le sms
      message = "Mr/Mme #{@data.name} vous avez un compte sur la plateforme. EPOLICE"
      HTTParty.get("https://www.agis-as.com/epolice/index.php?telephone=#{@data.phone}&message=#{message}")
      redirect_to access_users_path
    else
      render :admin_show
    end
  end

  #adition d'un administrateur
  # @developer: mailto:mvondoyannick@gmail.com
  def admin_edit
    admin = params[:data]
    @admin = Admin.find(admin)
    add_breadcrumb 'utilisateurs', :parametre_admin_path
    add_breadcrumb 'administrateurs', :parametre_admins_admin_show_path
    add_breadcrumb 'edition', :parametre_admin_edit_path
    render layout: 'fylo'
  end

  #liste de tous les GRVPC
  def grvpc_show
    @grvpc = Grvpc.order(email: :asc)
    add_breadcrumb 'utilisateurs', :parametre_admin_path
    add_breadcrumb 'GRVPC', :access_grvpc_show_path
    render layout: 'fylo'
  end

  #Ajout d'un nouveau compte GRVPC
  def grvpc_new
    @data = Grvpc.new(grvpc_params)
    #on sauvegarde les informations
    if @data.save

    else

    end
    render layout: 'fylo'
  end

  #ajout du personnel de metropolis
  def metropolis_show
    @user = Metropoli.all
    render layout: 'fylo'
  end

  #ajout des assurances
  def assurance_show
    @user = Assurance.all
    #render layout: 'fylo'
    render layout: 'views/index'
  end

  #pour la gestion de l'aide sur l'application
  def yelp
    #render layout: 'fylo'
    render layout: 'views/index'
  end

  def transfert
    @transfert = Transfert.order(created_at: :desc).last(100)
    render layout: 'views/index'
  end

  #mon brouillon
  def draft

  end

  private

  def admin_params
    params.permit(:name, :prenom, :email, :password, :password_confirmation, :role_id)
    render layout: 'views/index'
  end

  def grvpc_params
    params.permit(:email, :password, :password_confirmation, :matricule, :phone)
  end


end
