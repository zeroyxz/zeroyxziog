<%@ Assembly Name="Microsoft.SharePoint.IdentityModel, Version=15.0.0.0, Culture=neutral, PublicKeyToken=71e9bce111e9429c" %>
<%@ Register Tagprefix="SharepointIdentity" Namespace="Microsoft.SharePoint.IdentityModel" Assembly="Microsoft.SharePoint.IdentityModel, Version=15.0.0.0, Culture=neutral, PublicKeyToken=71e9bce111e9429c" %>
<%@ Assembly Name="Microsoft.SharePoint, Version=15.0.0.0, Culture=neutral, PublicKeyToken=71e9bce111e9429c"%>
<%@ Page Language="C#" Inherits="Microsoft.SharePoint.IdentityModel.Pages.MultiLogonPage" MasterPageFile="~/_layouts/15/errorv15.master"       %>
<%@ Import Namespace="Microsoft.SharePoint.WebControls" %> 
<%@ Register Tagprefix="SharePoint" Namespace="Microsoft.SharePoint.WebControls" Assembly="Microsoft.SharePoint, Version=15.0.0.0, Culture=neutral, PublicKeyToken=71e9bce111e9429c" %> 
<%@ Register Tagprefix="Utilities" Namespace="Microsoft.SharePoint.Utilities" Assembly="Microsoft.SharePoint, Version=15.0.0.0, Culture=neutral, PublicKeyToken=71e9bce111e9429c" %> 
<%@ Import Namespace="Microsoft.SharePoint" %> <%@ Assembly Name="Microsoft.Web.CommandUI, Version=15.0.0.0, Culture=neutral, PublicKeyToken=71e9bce111e9429c" %>

<asp:Content ContentPlaceHolderID="PlaceHolderAdditionalPageHead" runat="server">
    <link href="iog/stylesheets/IOG.css" type="text/css" rel="stylesheet" />
</asp:Content>

<asp:Content ContentPlaceHolderId="PlaceHolderPageTitle" runat="server">
    <SharePoint:EncodedLiteral runat="server"  EncodeMethod="HtmlEncode" Id="ClaimsLogonPageTitle" />
</asp:Content>
<asp:Content ContentPlaceHolderId="PlaceHolderPageTitleInTitleArea" runat="server">
    <!-- Removed by PW - <SharePoint:EncodedLiteral runat="server"  EncodeMethod="HtmlEncode" Id="ClaimsLogonPageTitleInTitleArea" /> -->
</asp:Content>
<asp:Content ContentPlaceHolderId="PlaceHolderMain" runat="server">
    
    <!-- The modal Conditions of Use section-->
    <div id="ModalConditions" class="modal">
        <div id="ConditionsPopUp" class="modal-inner">

            <!-- Modal content -->
            <div id="ModalContent" class="modal-content">
                <p class="modal-content-title  modal-emphasis">Conditions of Use</p>
                <p>You are entering a UK Information System that is provided for caveattexthere use</p>
                <p>By using this system you are consenting to use it in accordance with the UK <a href="http://fvey.diif.s.mil.uk/sitecollectiondocuments/non%20authenticated%20documents/20160329-Web_Portal_Security_Instructions_v1.pdf">Web Portal Security Instructions</a></p>
                <p class="modal-emphasis">Use of this system is routinely monitored, recorded and audited to ensure that users are carrying out their responsibilities</p>
                <p>Breaches of the Web Portal Security Instructions may render the offender liable to disciplinary action</p>

            </div>
            <div id="ModalContentButton" class="modal-content-btn">
                <img id="btnClose" alt="Click to agree" src="iog/images/agree.png" />
            </div>      
        </div>
    </div>

<!-- Login Window additional information -->
    <div class="login-window">
        <div class="login-window-1009">
            <img src="iog/images/MoD_masthead.png" alt="MoD Banner" />
            
            <div class="nation-images">
                
                caveatimageshere
                
            </div>

            <div class="login-text"> 
		<p>The drop-down below presents two options. Select &apos;FVEY_CWE&apos; if you are a United Kingdom user and are accessing the SharePoint site from MODNet, DII, etc.;  you should be automatically logged in.  
			If you are a user from one of the other FVEY nations you should select &apos;Windows Authentication&apos;. When prompted, enter UKFVEY\&lt;userid&gt; into the Username field and your UK Pegasus password into the Password field. </p>
           
                <p>If you are unsure which option to select please refer to the <a href="http://fvey.diif.s.mil.uk/pages/FrequentlyAskedQuestions.aspx">Frequently Asked Question</a> page.</p>
            
                <p>Select the credentials you want to use to logon to this Sharepoint site:</p>

                Sign In <SharepointIdentity:LogonSelector ID="ClaimsLogonSelector" runat="server" />
            </div>
        </div>
        <!-- Removed by PW - <SharePoint:EncodedLiteral runat="server"  EncodeMethod="HtmlEncode" Id="ClaimsLogonPageMessage" />
        <br />
        <br /> -->
    </div>
    

    <script type="text/javascript">
        // Get the modal
        var modal = document.getElementById('ModalConditions');

        // Get the element that closes the modal
        var span = document.getElementById("btnClose");

        span.onclick = function () {
            modal.style.display = "none";
        }
    </script>
</asp:Content>
