<%@ Assembly Name="Microsoft.SharePoint.IdentityModel, Version=15.0.0.0, Culture=neutral, PublicKeyToken=71e9bce111e9429c" %>
<%@ Register Tagprefix="SharepointIdentity" Namespace="Microsoft.SharePoint.IdentityModel" Assembly="Microsoft.SharePoint.IdentityModel, Version=15.0.0.0, Culture=neutral, PublicKeyToken=71e9bce111e9429c" %>
<%@ Assembly Name="Microsoft.SharePoint, Version=15.0.0.0, Culture=neutral, PublicKeyToken=71e9bce111e9429c"%>
<%@ Page Language="C#" Inherits="Microsoft.SharePoint.IdentityModel.Pages.MultiLogonPage" MasterPageFile="~/_layouts/15/errorv15.master"       %>
<%@ Import Namespace="Microsoft.SharePoint.WebControls" %> 
<%@ Register Tagprefix="SharePoint" Namespace="Microsoft.SharePoint.WebControls" Assembly="Microsoft.SharePoint, Version=15.0.0.0, Culture=neutral, PublicKeyToken=71e9bce111e9429c" %> 
<%@ Register Tagprefix="Utilities" Namespace="Microsoft.SharePoint.Utilities" Assembly="Microsoft.SharePoint, Version=15.0.0.0, Culture=neutral, PublicKeyToken=71e9bce111e9429c" %> 
<%@ Import Namespace="Microsoft.SharePoint" %> <%@ Assembly Name="Microsoft.Web.CommandUI, Version=15.0.0.0, Culture=neutral, PublicKeyToken=71e9bce111e9429c" %>

<asp:Content ContentPlaceHolderID="PlaceHolderAdditionalPageHead" runat="server">
    <link href="IOGLogin.css" type="text/css" rel="stylesheet" />
</asp:Content>

<asp:Content ContentPlaceHolderId="PlaceHolderPageTitle" runat="server">
    5Eyes - 
	<SharePoint:EncodedLiteral runat="server"  EncodeMethod="HtmlEncode" Id="ClaimsLogonPageTitle" />
</asp:Content>
<asp:Content ContentPlaceHolderId="PlaceHolderPageTitleInTitleArea" runat="server">
	5Eyes - 
    <SharePoint:EncodedLiteral runat="server"  EncodeMethod="HtmlEncode" Id="ClaimsLogonPageTitleInTitleArea" />
</asp:Content>
<asp:Content ContentPlaceHolderId="PlaceHolderMain" runat="server">
    <!-- The Modal -->
    <div id="myModal" class="modal">
        <div id="myModalInner" class="modal-inner">
            <!-- Modal content -->
            <div id="myModalContent" class="modal-content">                
                <p>Please click the Agree button to confirm you agree to the Terms and Conditions of using this site or leave the site by closing your browser window.</p>
            </div>
            <div id="myModalContentButtonDiv" class="modal-content-div">
                <div id="col1" class="col">&nbsp;</div>
                <div id="col2" class="col col-with-btn"><span id="btnClose" class="close">Agree</span></div>
                <div id="col3" class="col"></div>
            </div>            
            
        </div>
    </div>
    <div class="login-text"><img src="5eyes.png" alt="5Eyes" /><span>The drop down below will present you with two choices for you to select from.  You should select the <b>Windows Authentication</b> in the drop down if you're a user from the United Kingdom and accessing the web site via a DIIF UAD.  If you're a user from one the the other 5Eye's nations you should select the <b>Forms</b> option.  If you are unsure which option to select please contact you Adminstrator or We Support on 111-222-333</span></div>
<SharePoint:EncodedLiteral runat="server"  EncodeMethod="HtmlEncode" Id="ClaimsLogonPageMessage" />
<br />
<br />
<SharepointIdentity:LogonSelector ID="ClaimsLogonSelector" runat="server" />
    <script type="text/javascript">
        // Get the modal
        var modal = document.getElementById('myModal');

        // Get the <span> element that closes the modal
        var span = document.getElementById("btnClose");

        span.onclick = function () {
            modal.style.display = "none";
        }
    </script>
</asp:Content>
