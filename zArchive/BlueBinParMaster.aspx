<%@ Page Title="BlueBin Par Master" Language="VB" MasterPageFile="~/Site.Master" AutoEventWireup="true" CodeFile="BlueBinParMaster.aspx.vb" Inherits="BlueBinParMaster" %>

    <asp:Content ID="BodyContent" ContentPlaceHolderID="MainContent" runat="server">

<asp:Table ID="PageTable" runat="server" >
<asp:TableRow><asp:TableCell><h2><%: Title %></h2>
    <p>Welcome to the Custom BlueBin ParMaster.</p>
    <p>
            <asp:LinkButton ID="ParMasterB" runat="server" class="btn btn-default">Par Master</asp:LinkButton>&nbsp;
            <asp:LinkButton ID="ItemMasterB" runat="server" class="btn btn-default">Item Master</asp:LinkButton>&nbsp;
            <asp:LinkButton ID="LocationMasterB" runat="server" class="btn btn-default">Location Master</asp:LinkButton>&nbsp;
        </p>
              </asp:TableCell></asp:TableRow>
<asp:TableRow Height="5"></asp:TableRow>
  <asp:TableRow><asp:TableCell>
        <asp:Table runat="server" ID="SearchTable">
                <asp:TableRow><asp:TableCell><asp:Label runat="server" id="FacilityL">Facility:&nbsp;&nbsp;&nbsp;&nbsp;</asp:Label></asp:TableCell><asp:TableCell><asp:TextBox ID="FacilitySB" runat="server" Width="150px"></asp:TextBox></asp:TableCell></asp:TableRow>
            <asp:TableRow Height="5px"></asp:TableRow>
                <asp:TableRow><asp:TableCell><asp:Label runat="server" id="LocationL">Location:&nbsp;</asp:Label></asp:TableCell><asp:TableCell><asp:TextBox ID="LocationSB" runat="server" Width="200px"></asp:TextBox></asp:TableCell></asp:TableRow>
            <asp:TableRow Height="5px"></asp:TableRow>
                <asp:TableRow><asp:TableCell><asp:Label runat="server" id="ItemL">Item:&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;</asp:Label></asp:TableCell><asp:TableCell><asp:TextBox ID="ItemSB" runat="server" Width="200px"></asp:TextBox></asp:TableCell></asp:TableRow>
            <asp:TableRow Height="5px"></asp:TableRow>
                <asp:TableRow><asp:TableCell><asp:Button ID="LinkButton1" runat="server" CausesValidation="False" Text="Search"></asp:Button></asp:TableCell></asp:TableRow>
                
            <asp:TableRow Height="10px"></asp:TableRow>
            </asp:Table>
    </asp:TableCell></asp:TableRow>
    
       <asp:TableRow>
    <asp:TableCell Width="500px"  >
        <asp:Label runat="server" id="hiddenParMaster"><h3>Par Master</h3></asp:Label>
            <p> 
        <asp:GridView ID="GridViewParMaster"  OnRowCommand="GridViewParMaster_RowCommand" CssClass="GridViewitem" runat="server" BackColor="White" BorderColor="#999999" BorderStyle="None" BorderWidth="1px" CellPadding="3" GridLines="Vertical" DataSourceID="ParMasterDataSource" AutoGenerateColumns="False" DataKeyNames="ParMasterID" AllowSorting="True" AllowPaging="True" ShowFooter="True" PageSize="20">
        <AlternatingRowStyle BackColor="#DCDCDC"></AlternatingRowStyle>

        <Columns>
            <asp:TemplateField ShowHeader="False">
                <EditItemTemplate>
                    <asp:Button runat="server" Text="Update" CommandName="Update" CausesValidation="True" ValidationGroup="EditParMaster" ID="Button1"></asp:Button>&nbsp;<asp:Button runat="server" Text="Cancel" CommandName="Cancel" CausesValidation="False" ID="Button2"></asp:Button>
                </EditItemTemplate>
                <ItemTemplate>
                    <asp:Button runat="server" Text="Edit" CommandName="Edit" CausesValidation="False" ID="Button1"></asp:Button>
                </ItemTemplate>
                <FooterTemplate><asp:LinkButton ID="ParMasterInsert" runat="server" Text="Add" CausesValidation="True" ValidationGroup="AddParMaster"  CommandName="ParMasterInsert"></asp:LinkButton></FooterTemplate>
            </asp:TemplateField>
            
            <asp:TemplateField HeaderText="ParMasterID" InsertVisible="False" SortExpression="ParMasterID" Visible ="False">
                <EditItemTemplate>
                    <asp:Label runat="server" Text='<%# Eval("ParMasterID") %>' ID="ETIDL"></asp:Label>
                </EditItemTemplate>
                <ItemTemplate>
                    <asp:Label runat="server" Text='<%# Bind("ParMasterID") %>' ID="ITIDL"></asp:Label>
                </ItemTemplate>
            </asp:TemplateField>
            <asp:TemplateField HeaderText="FacilityID" SortExpression="FacilityID" Visible ="False">
                
                <ItemTemplate>
                    <asp:Label runat="server" Text='<%# Bind("FacilityID") %>' ID="FacilityIDLabel2"></asp:Label>
                </ItemTemplate>
                
            </asp:TemplateField>
            
       

            <asp:TemplateField HeaderText="Facility Name" SortExpression="FacilityName">    
                 
                <ItemTemplate>
                    <asp:Label runat="server" Text='<%# Bind("FacilityName") %>' ID="FacilityNameLabel2"></asp:Label>
                </ItemTemplate>
                <FooterTemplate>
                    <asp:DropDownList runat="server" ID="FacilityDDF" DataSourceID="FacilityDataSource" DataTextField="FacilityName" DataValueField="FacilityID">
                    </asp:DropDownList></FooterTemplate>
            </asp:TemplateField>

            <asp:TemplateField HeaderText="Location ID" SortExpression="LocationID" Visible ="True">
                
                <ItemTemplate>
                    <asp:Label runat="server" Text='<%# Bind("LocationID") %>' ID="LocationIDLabel2"></asp:Label>
                </ItemTemplate>
                
            </asp:TemplateField>
            
            <asp:TemplateField HeaderText="Location Name" SortExpression="LocationName">
               <%-- <EditItemTemplate>
                    <asp:DropDownList runat="server" ID="LocationDD" SelectedValue='<%# Eval("LocationName").ToString().Trim()%>'  DataSourceID="LocationDataSource" DataTextField="LocationName" DataValueField="LocationID" Width="75">
                    </asp:DropDownList>
                </EditItemTemplate>--%>
                <ItemTemplate>
                    <asp:Label runat="server" Text='<%# Bind("LocationName") %>' ID="Label2" ></asp:Label>
                    
                </ItemTemplate>
                <FooterTemplate>
                    <asp:DropDownList runat="server" ID="LocationDDF" DataSourceID="LocationDataSource" DataTextField="LocationName" DataValueField="LocationID" Width="75">
                        <asp:ListItem Selected = "True" Text = "--Select--" Value = ""></asp:ListItem>
                    </asp:DropDownList>
                    
                </FooterTemplate>
            </asp:TemplateField>
                <asp:TemplateField HeaderText="ItemID" SortExpression="ItemID" Visible ="True">
                
                <ItemTemplate>
                    <asp:Label runat="server" Text='<%# Bind("ItemID") %>' ID="ItemIDLabel2"></asp:Label>
                </ItemTemplate>
                
            </asp:TemplateField>
            <asp:TemplateField HeaderText="Item" SortExpression="ItemDescription">
<%--                <EditItemTemplate>
                    <asp:DropDownList runat="server" ID="ItemDD" SelectedValue='<%# Bind("ItemDescription") %>' DataSourceID="ItemDataSource" DataTextField="ItemDescription" DataValueField="ItemID">
                    </asp:DropDownList>
                </EditItemTemplate>--%>
                <ItemTemplate>
                    <asp:Label runat="server" Text='<%# Bind("ItemDescription") %>' ID="Label3" ></asp:Label>
                </ItemTemplate>
                <FooterTemplate>
                    <asp:DropDownList runat="server" ID="ItemDDF" DataSourceID="ItemDataSource" DataTextField="ExtendedDescription" DataValueField="ItemID">
                        <asp:ListItem Selected = "True" Text = "--Select--" Value = ""></asp:ListItem>
                    </asp:DropDownList>
                </FooterTemplate>
            </asp:TemplateField>
             
            <asp:TemplateField HeaderText="Bin Sequence" SortExpression="BinSequence">    
                <ItemTemplate>
                    <asp:Label runat="server" Text='<%# Bind("BinSequence") %>' ID="BinSequenceLabel2"></asp:Label>
                </ItemTemplate>
				<EditItemTemplate>
                    <asp:TextBox runat="server" Width="80px" Text='<%# Bind("BinSequence") %>' ID="BinSequenceTB"></asp:TextBox>
                </EditItemTemplate>
                <FooterTemplate>
                    <asp:TextBox runat="server" Width="80px" ID="BinSequenceF"></asp:TextBox>
				</FooterTemplate>
</asp:TemplateField>

            <asp:TemplateField HeaderText="UOM" SortExpression="BinUOM">    
                <ItemTemplate>
                    <asp:Label runat="server" Text='<%# Bind("BinUOM") %>' ID="BinUOMLabel2"></asp:Label>
                </ItemTemplate>
				<EditItemTemplate>
                    <asp:DropDownList runat="server" ID="BinUOMDD" SelectedValue='<%# Bind("BinUOM") %>' DataSourceID="BinUOMDataSource" DataTextField="BinUOM" DataValueField="BinUOM">
                    </asp:DropDownList>
                </EditItemTemplate>
                <FooterTemplate>
                    <asp:DropDownList runat="server" ID="BinUOMDDF" DataSourceID="BinUOMDataSource" DataTextField="BinUOM" DataValueField="BinUOM">
                    </asp:DropDownList>
				</FooterTemplate>
</asp:TemplateField>

            <asp:TemplateField HeaderText="Par" SortExpression="BinQuantity">    
                <ItemTemplate>
                    <asp:Label runat="server" Text='<%# Bind("BinQuantity") %>' ID="BinQuantityLabel2"  DataFormatString="{0:#}"></asp:Label>
                </ItemTemplate>
				<EditItemTemplate>
                    <asp:TextBox runat="server" Width="30px" Text='<%# Bind("BinQuantity") %>' ID="BinQuantityTB"></asp:TextBox>
                </EditItemTemplate>
                <FooterTemplate>
                    <asp:TextBox runat="server" Width="30px" ID="BinQuantityF"></asp:TextBox>
				</FooterTemplate>
</asp:TemplateField>

            <asp:TemplateField HeaderText="Lead Time" SortExpression="LeadTime">    
                <ItemTemplate>
                    <asp:Label runat="server" Text='<%# Bind("LeadTime") %>' ID="LeadTimeLabel2"  DataFormatString="{0:###}"></asp:Label>
                </ItemTemplate>
				<EditItemTemplate>
                        <asp:DropDownList runat="server"  AutoPostBack="False" ID="BinLeadTimeDD" SelectedValue=<%#Bind("LeadTime")%>>
                        <asp:ListItem Value="0">0</asp:ListItem>
                        <asp:ListItem Value="1">1</asp:ListItem>
                            <asp:ListItem Value="2">2</asp:ListItem>
                            <asp:ListItem Value="3">3</asp:ListItem>
                            <asp:ListItem Value="4">4</asp:ListItem>
                            <asp:ListItem Value="5">5</asp:ListItem>
                            <asp:ListItem Value="6">6</asp:ListItem>
                            <asp:ListItem Value="7">7</asp:ListItem>
                            <asp:ListItem Value="8">8</asp:ListItem>
                            <asp:ListItem Value="9">9</asp:ListItem>
                            <asp:ListItem Value="10">10</asp:ListItem>
                    </asp:DropDownList>
                </EditItemTemplate>
                <FooterTemplate>
                    <asp:DropDownList runat="server"  AutoPostBack="False" ID="BinLeadTimeDDF" >
                        <asp:ListItem Value="0">0</asp:ListItem>
                        <asp:ListItem Value="1">1</asp:ListItem>
                            <asp:ListItem Value="2">2</asp:ListItem>
                            <asp:ListItem Value="3">3</asp:ListItem>
                            <asp:ListItem Value="4">4</asp:ListItem>
                            <asp:ListItem Value="5">5</asp:ListItem>
                            <asp:ListItem Value="6">6</asp:ListItem>
                            <asp:ListItem Value="7">7</asp:ListItem>
                            <asp:ListItem Value="8">8</asp:ListItem>
                            <asp:ListItem Value="9">9</asp:ListItem>
                            <asp:ListItem Value="10">10</asp:ListItem>
                    </asp:DropDownList>
				</FooterTemplate>
</asp:TemplateField>

            <asp:TemplateField HeaderText="Item Type" SortExpression="ItemType">    
                <ItemTemplate>
                    <asp:Label runat="server" Text='<%# Bind("ItemType") %>' ID="ItemTypeLabel2"></asp:Label>
                </ItemTemplate>
				<EditItemTemplate>
                    <asp:TextBox runat="server" Width="80px" Text='<%# Bind("ItemType") %>' ID="ItemTypeTB"></asp:TextBox>
                </EditItemTemplate>
                <FooterTemplate>
                    <asp:TextBox runat="server" Width="80px" ID="ItemTypeF"></asp:TextBox>
				</FooterTemplate>
</asp:TemplateField>


            <asp:TemplateField HeaderText="WH LocationID" SortExpression="WHLocationID">    
                <ItemTemplate>
                    <asp:Label runat="server" Text='<%# Bind("WHLocationID") %>' ID="WHLocationIDLabel2"></asp:Label>
                </ItemTemplate>
				<EditItemTemplate>
                    <asp:TextBox runat="server" Width="80px" Text='<%# Bind("WHLocationID") %>' ID="WHLocationIDTB"></asp:TextBox>
                </EditItemTemplate>
                <FooterTemplate>
                    <asp:TextBox runat="server" Width="80px" ID="WHLocationIDF"></asp:TextBox>
				</FooterTemplate>
</asp:TemplateField>

            <asp:TemplateField HeaderText="WH Sequence" SortExpression="WHSequence">    
                <ItemTemplate>
                    <asp:Label runat="server" Text='<%# Bind("WHSequence") %>' ID="WHSequenceLabel2"></asp:Label>
                </ItemTemplate>
				<EditItemTemplate>
                    <asp:TextBox runat="server" Width="80px" Text='<%# Bind("WHSequence") %>' ID="WHSequenceTB"></asp:TextBox>
                </EditItemTemplate>
                <FooterTemplate>
                    <asp:TextBox runat="server" Width="80px" ID="WHSequenceF"></asp:TextBox>
				</FooterTemplate>
</asp:TemplateField>

            <asp:TemplateField HeaderText="Patient Charge" SortExpression="PatientCharge">    
                <ItemTemplate>
                    <asp:Label runat="server" Text='<%# Bind("PatientChargeName") %>' ID="PatientChargeLabel2"  DataFormatString="{0:###}"></asp:Label>
                </ItemTemplate>
				<EditItemTemplate>
                         <asp:DropDownList runat="server"  AutoPostBack="False" ID="PatientChargeDD" SelectedValue=<%#Bind("PatientCharge")%>>
                        <asp:ListItem Value="1">Yes</asp:ListItem>
                        <asp:ListItem Value="0">No</asp:ListItem>
                    </asp:DropDownList>
                </EditItemTemplate>
                <FooterTemplate>
                        <asp:DropDownList runat="server"  AutoPostBack="False" ID="PatientChargeDDF">
                        <asp:ListItem Value="1">Yes</asp:ListItem>
                        <asp:ListItem Value="0">No</asp:ListItem>
                    </asp:DropDownList>
				</FooterTemplate>
</asp:TemplateField>
            <asp:TemplateField HeaderText="ERP Updated" SortExpression="Updated" Visible ="True">
                
                <ItemTemplate>
                    <asp:Label runat="server" Text='<%# Bind("UpdatedName") %>' ID="UpdatedLabel2"></asp:Label>
                </ItemTemplate>
                
            </asp:TemplateField>

            <asp:TemplateField HeaderText="Last Updated" SortExpression="LastUpdated" Visible ="True">
                
                <ItemTemplate>
                    <asp:Label runat="server" Text='<%# Bind("LastUpdated", "{0:d}") %>' ID="LastUpdatedLabel2"  DataFormatString="{0:d}"></asp:Label>
                </ItemTemplate>
                
            </asp:TemplateField>
            
            
            <asp:TemplateField ShowHeader="False">
             <ItemTemplate>
            <asp:LinkButton ID="DeleteParMasterLB" runat="server" CommandName="Delete" OnClientClick="return confirm('Are you sure you want to delete this ParMaster Entry?');">Delete</asp:LinkButton>             
            </ItemTemplate>
            </asp:TemplateField>


            
        </Columns>

        <FooterStyle BackColor="#CCCCCC" ForeColor="Black"></FooterStyle>

        <HeaderStyle BackColor="#000084" Font-Bold="True" ForeColor="White"></HeaderStyle>

        <PagerStyle HorizontalAlign="Center" BackColor="#999999" ForeColor="Black"></PagerStyle>

        <RowStyle BackColor="#EEEEEE" ForeColor="Black"></RowStyle>

        <SelectedRowStyle BackColor="#008A8C" Font-Bold="True" ForeColor="White"></SelectedRowStyle>

        <SortedAscendingCellStyle BackColor="#F1F1F1"></SortedAscendingCellStyle>

        <SortedAscendingHeaderStyle BackColor="#0000A9"></SortedAscendingHeaderStyle>

        <SortedDescendingCellStyle BackColor="#CAC9C9"></SortedDescendingCellStyle>

        <SortedDescendingHeaderStyle BackColor="#000065"></SortedDescendingHeaderStyle>
    </asp:GridView>
 
        </p>
        </asp:TableCell> </asp:TableRow>
<asp:TableRow>
<asp:TableCell Width="500px"  >
<asp:Label runat="server" id="hiddenItemMaster"><h3>Item Master</h3><p></asp:Label>
        <asp:GridView ID="GridViewItemMaster" OnRowCommand="GridViewItemMaster_RowCommand" CssClass="GridViewitem" runat="server" BackColor="White" BorderColor="#999999" BorderStyle="None" BorderWidth="1px" CellPadding="3" GridLines="Vertical" DataSourceID="ItemMasterDataSource" AutoGenerateColumns="False" DataKeyNames="ItemMasterID" AllowSorting="True" AllowPaging="True" ShowFooter="True">
        <AlternatingRowStyle BackColor="#DCDCDC"></AlternatingRowStyle>

        <Columns>
            <asp:TemplateField ShowHeader="False">
                 <EditItemTemplate>
                    <asp:Button runat="server" Text="Update" CommandName="Update" CausesValidation="True" ValidationGroup="EditItem" ID="Button1"></asp:Button>&nbsp;<asp:Button runat="server" Text="Cancel" CommandName="Cancel" CausesValidation="False" ID="Button2"></asp:Button>
                </EditItemTemplate>
                <ItemTemplate>
                    <asp:Button runat="server" Text="Edit" CommandName="Edit" CausesValidation="False" ID="Button1"></asp:Button>
                </ItemTemplate>
                <FooterTemplate><asp:LinkButton ID="ItemInsert" runat="server" Text="Add" CausesValidation="True" ValidationGroup="AddItem"  CommandName="ItemInsert"></asp:LinkButton></FooterTemplate>
            </asp:TemplateField>

            <asp:TemplateField HeaderText="ID" InsertVisible="False" SortExpression="ItemMasterID" Visible="False">
                <EditItemTemplate>
                    <asp:Label runat="server" Text='<%# Eval("ItemMasterID") %>' ID="ETIML"></asp:Label>
                </EditItemTemplate>
                <ItemTemplate>
                    <asp:Label runat="server" Text='<%# Bind("ItemMasterID") %>' ID="ITIML"></asp:Label>
                </ItemTemplate>
            </asp:TemplateField>
            
            <asp:TemplateField HeaderText="ItemID" InsertVisible="False" SortExpression="ItemID">
                <EditItemTemplate>
                    <asp:Label runat="server" Text='<%# Eval("ItemID") %>' ID="ITItemIDL"></asp:Label>
                </EditItemTemplate>
                <ItemTemplate>
                    <asp:Label runat="server" Text='<%# Bind("ItemID") %>' ID="ETItemIDL"></asp:Label>
                </ItemTemplate>
                <FooterTemplate><asp:TextBox runat="server" ID="ItemID"></asp:TextBox><asp:RequiredFieldValidator ID="RequiredFieldValidatorItemID" ValidationGroup="AddItemID" runat="server" ControlToValidate="ItemID" Display="Dynamic" ForeColor="Red" Font-Size="X-Small">REQUIRED</asp:RequiredFieldValidator></FooterTemplate>

            </asp:TemplateField>
            <asp:TemplateField HeaderText="ItemDescription" SortExpression="ItemDescription">
                <EditItemTemplate>
                    <asp:TextBox runat="server" Text='<%# Bind("ItemDescription") %>' ID="EditItemDescription"></asp:TextBox><asp:RequiredFieldValidator ID="RequiredFieldValidatorItemDescription" ValidationGroup="EditItemDescription" runat="server" ControlToValidate="EditItemDescription" Display="Dynamic" ForeColor="Red" Font-Size="X-Small">REQUIRED</asp:RequiredFieldValidator>
                <ItemStyle Wrap="False" Width="150px"></ItemStyle>

                </EditItemTemplate>
                <ItemTemplate>
                    <asp:Label runat="server" Text='<%# Bind("ItemDescription") %>' ID="LabelItemDescription"></asp:Label>
                </ItemTemplate>
                <FooterTemplate><asp:TextBox runat="server" ID="ItemDescription"></asp:TextBox><asp:RequiredFieldValidator ID="RequiredFieldValidatorItemDescription" ValidationGroup="AddItemDescription" runat="server" ControlToValidate="ItemDescription" Display="Dynamic" ForeColor="Red" Font-Size="X-Small">REQUIRED</asp:RequiredFieldValidator>
                    <ItemStyle Wrap="False" Width="150px"></ItemStyle>
                </FooterTemplate>
            </asp:TemplateField>
            <asp:TemplateField HeaderText="ClinicalDescription" SortExpression="ClinicalDescription">
                <EditItemTemplate>
                    <asp:TextBox runat="server" Text='<%# Bind("ClinicalDescription") %>' ID="ClinicalDescription"></asp:TextBox><asp:RequiredFieldValidator ID="RequiredFieldValidatorClinicalDescription" ValidationGroup="EditClinicalDescription" runat="server" ControlToValidate="EditClinicalDescription" Display="Dynamic" ForeColor="Red" Font-Size="X-Small">REQUIRED</asp:RequiredFieldValidator>
                <ItemStyle Wrap="False" Width="150px"></ItemStyle>

                </EditItemTemplate>
                <ItemTemplate>
                    <asp:Label runat="server" Text='<%# Bind("ItemDescription2") %>' ID="LabelClinicalDescription"></asp:Label>
                </ItemTemplate>
                <FooterTemplate><asp:TextBox runat="server" ID="ItemClinicalDescription"></asp:TextBox><asp:RequiredFieldValidator ID="RequiredFieldValidatorClinicalDescription" ValidationGroup="AddClinicalDescription" runat="server" ControlToValidate="ClinicalDescription" Display="Dynamic" ForeColor="Red" Font-Size="X-Small">REQUIRED</asp:RequiredFieldValidator>
                    <ItemStyle Wrap="False" Width="150px"></ItemStyle>
                </FooterTemplate>
            </asp:TemplateField>
            <asp:TemplateField HeaderText="Manufacturer" InsertVisible="False" SortExpression="Manufacturer">
                <ItemTemplate>
                    <asp:Label runat="server" Text='<%# Bind("Manufacturer") %>' ID="ManufacturerL"></asp:Label>
                </ItemTemplate>
            </asp:TemplateField>
             <asp:TemplateField HeaderText="ManufacturerNo" InsertVisible="False" SortExpression="ManufacturerNo">
                <ItemTemplate>
                    <asp:Label runat="server" Text='<%# Bind("ManufacturerNo") %>' ID="ManufacturerNoL"></asp:Label>
                </ItemTemplate>
            </asp:TemplateField>
            <asp:TemplateField HeaderText="Vendor" InsertVisible="False" SortExpression="Vendor">
                <ItemTemplate>
                    <asp:Label runat="server" Text='<%# Bind("Vendor") %>' ID="VendorL"></asp:Label>
                </ItemTemplate>
            </asp:TemplateField>
             <asp:TemplateField HeaderText="VendorNo" InsertVisible="False" SortExpression="VendorNo">
                <ItemTemplate>
                    <asp:Label runat="server" Text='<%# Bind("VendorNo") %>' ID="VendorNoL"></asp:Label>
                </ItemTemplate>
            </asp:TemplateField>
            <asp:TemplateField HeaderText="VendorItemID" InsertVisible="False" SortExpression="VendorItemID">
                <ItemTemplate>
                    <asp:Label runat="server" Text='<%# Bind("VendorItemID") %>' ID="VendorItemIDL"></asp:Label>
                </ItemTemplate>
            </asp:TemplateField>
            <asp:TemplateField HeaderText="LastPO" InsertVisible="False" SortExpression="LastPODate">
                <ItemTemplate>
                    <asp:Label runat="server" Text='<%# Bind("LastPODate", "{0:d}") %>' ID="LastPODateL"></asp:Label>
                </ItemTemplate>
            </asp:TemplateField>
            <asp:TemplateField HeaderText="StockUOM" InsertVisible="False" SortExpression="StockUOM">
                <ItemTemplate>
                    <asp:Label runat="server" Text='<%# Bind("StockUOM") %>' ID="StockUOML"></asp:Label>
                </ItemTemplate>
            </asp:TemplateField>

        </Columns>
        <FooterStyle BackColor="#CCCCCC" ForeColor="Black"></FooterStyle>
        <HeaderStyle BackColor="#000084" Font-Bold="True" ForeColor="White"></HeaderStyle>
        <PagerStyle HorizontalAlign="Center" BackColor="#999999" ForeColor="Black"></PagerStyle>
        <RowStyle BackColor="#EEEEEE" ForeColor="Black"></RowStyle>
        <SelectedRowStyle BackColor="#008A8C" Font-Bold="True" ForeColor="White"></SelectedRowStyle>
        <SortedAscendingCellStyle BackColor="#F1F1F1"></SortedAscendingCellStyle>
        <SortedAscendingHeaderStyle BackColor="#0000A9"></SortedAscendingHeaderStyle>
        <SortedDescendingCellStyle BackColor="#CAC9C9"></SortedDescendingCellStyle>
        <SortedDescendingHeaderStyle BackColor="#000065"></SortedDescendingHeaderStyle>
    </asp:GridView>
 
        </p>
</asp:TableCell> </asp:TableRow>

<asp:TableRow>
<asp:TableCell Width="500px"  >
<asp:Label runat="server" id="hiddenLocationMaster"><h3>Location Master</h3><p></asp:Label>
        <asp:GridView ID="GridViewLocationMaster" OnRowCommand="GridViewLocationMaster_RowCommand" CssClass="GridViewitem" runat="server" BackColor="White" BorderColor="#999999" BorderStyle="None" BorderWidth="1px" CellPadding="3" GridLines="Vertical" DataSourceID="LocationMasterDataSource" AutoGenerateColumns="False" DataKeyNames="LocationMasterID" AllowSorting="True" AllowPaging="True" ShowFooter="True">
        <AlternatingRowStyle BackColor="#DCDCDC"></AlternatingRowStyle>

        <Columns>
            <asp:TemplateField ShowHeader="False">
                <EditItemTemplate>
                    <asp:Button runat="server" Text="Update" CommandName="Update" CausesValidation="True" ValidationGroup="EditLocation" ID="Button1"></asp:Button>&nbsp;<asp:Button runat="server" Text="Cancel" CommandName="Cancel" CausesValidation="False" ID="Button2"></asp:Button>
                </EditItemTemplate>
                <ItemTemplate>
                    <asp:Button runat="server" Text="Edit" CommandName="Edit" CausesValidation="False" ID="Button1"></asp:Button>
                </ItemTemplate>
                <FooterTemplate><asp:LinkButton ID="LocationInsert" runat="server" Text="Add" CausesValidation="True" ValidationGroup="AddLocation"  CommandName="LocationInsert"></asp:LinkButton></FooterTemplate>
            </asp:TemplateField>

                      <asp:TemplateField HeaderText="ID" InsertVisible="False" SortExpression="LocationMasterID" Visible="False">
                <EditItemTemplate>
                    <asp:Label runat="server" Text='<%# Eval("LocationMasterID") %>' ID="ETLML"></asp:Label>
                </EditItemTemplate>
                <ItemTemplate>
                    <asp:Label runat="server" Text='<%# Bind("LocationMasterID") %>' ID="ITLML"></asp:Label>
                </ItemTemplate>
            </asp:TemplateField>
            
             <asp:TemplateField HeaderText="LocationID" InsertVisible="False" SortExpression="LocationID">
                <EditItemTemplate>
                    <asp:Label runat="server" Text='<%# Eval("LocationID") %>' ID="Label1"></asp:Label>
                </EditItemTemplate>
                <ItemTemplate>
                    <asp:Label runat="server" Text='<%# Bind("LocationID") %>' ID="Label1"></asp:Label>
                </ItemTemplate>
                <FooterTemplate><asp:TextBox runat="server" ID="LocationID"></asp:TextBox><asp:RequiredFieldValidator ID="RequiredFieldValidatorLocationID" ValidationGroup="AddLocationID" runat="server" ControlToValidate="LocationID" Display="Dynamic" ForeColor="Red" Font-Size="X-Small">REQUIRED</asp:RequiredFieldValidator></FooterTemplate>

            </asp:TemplateField>
            <asp:TemplateField HeaderText="LocationName" SortExpression="LocationName">
                <EditItemTemplate>
                    <asp:TextBox runat="server" Text='<%# Bind("LocationName") %>' ID="EditLocationName"></asp:TextBox><asp:RequiredFieldValidator ID="RequiredFieldValidatorLocationName" ValidationGroup="EditLocationName" runat="server" ControlToValidate="EditLocationName" Display="Dynamic" ForeColor="Red" Font-Size="X-Small">REQUIRED</asp:RequiredFieldValidator>
                    <ItemStyle Wrap="False" Width="100px"></ItemStyle>
                </EditItemTemplate>
                <ItemTemplate>
                    <asp:Label runat="server" Text='<%# Bind("LocationName") %>' ID="Label2"></asp:Label>
                </ItemTemplate>
                <FooterTemplate><asp:TextBox runat="server" ID="LocationName"></asp:TextBox><asp:RequiredFieldValidator ID="RequiredFieldValidatorLocationName" ValidationGroup="AddLocationName" runat="server" ControlToValidate="LocationName" Display="Dynamic" ForeColor="Red" Font-Size="X-Small">REQUIRED</asp:RequiredFieldValidator>
                    <ItemStyle Wrap="False" Width="100px"></ItemStyle>
                </FooterTemplate>
                
            </asp:TemplateField>
            <asp:TemplateField HeaderText="Last Updated" InsertVisible="False" SortExpression="LastUpdated">

                <ItemTemplate>
                    <asp:Label runat="server" Text='<%# Bind("LastUpdated", "{0:d}") %>' ID="Label5"></asp:Label>
                </ItemTemplate>
            </asp:TemplateField>
             <asp:TemplateField ShowHeader="False">
             <ItemTemplate>
            <asp:LinkButton ID="DeleteLocationLB" runat="server" CommandName="Delete" OnClientClick="return confirm('Are you sure you want to delete this Location?  This will also Delete all ParMaster entries for this Location!!');">Delete</asp:LinkButton>             
            </ItemTemplate>
            </asp:TemplateField>
        </Columns>
        <FooterStyle BackColor="#CCCCCC" ForeColor="Black"></FooterStyle>
        <HeaderStyle BackColor="#000084" Font-Bold="True" ForeColor="White"></HeaderStyle>
        <PagerStyle HorizontalAlign="Center" BackColor="#999999" ForeColor="Black"></PagerStyle>
        <RowStyle BackColor="#EEEEEE" ForeColor="Black"></RowStyle>
        <SelectedRowStyle BackColor="#008A8C" Font-Bold="True" ForeColor="White"></SelectedRowStyle>
        <SortedAscendingCellStyle BackColor="#F1F1F1"></SortedAscendingCellStyle>
        <SortedAscendingHeaderStyle BackColor="#0000A9"></SortedAscendingHeaderStyle>
        <SortedDescendingCellStyle BackColor="#CAC9C9"></SortedDescendingCellStyle>
        <SortedDescendingHeaderStyle BackColor="#000065"></SortedDescendingHeaderStyle>
    </asp:GridView>
 

</asp:TableCell> </asp:TableRow>

            <asp:TableRow Height="10px"></asp:TableRow><asp:TableRow><asp:TableCell> 
            <asp:ImageButton ID="ExportParMaster" runat="Server" ImageUrl="~/img/ExportExcel.gif" OnClick="ExportToExcelParMaster" Height="25px" CausesValidation="False" />
            <asp:ImageButton ID="ExportItemMaster" runat="Server" ImageUrl="~/img/ExportExcel.gif" OnClick="ExportToExcelItemMaster" Height="25px" CausesValidation="False" />
            <asp:ImageButton ID="ExportLocationMaster" runat="Server" ImageUrl="~/img/ExportExcel.gif" OnClick="ExportToExcelLocationMaster" Height="25px" CausesValidation="False" />
                                                                 </asp:TableCell> </asp:TableRow>  
    </asp:Table>
  

<p>
        <asp:SqlDataSource runat="server" ID="ParMasterDataSource" ConnectionString='<%$ ConnectionStrings:Site_ConnectionString %>' 
            DeleteCommand="exec sp_DeleteBlueBinParMaster @ParMasterID" 
            SelectCommand="sp_SelectBlueBinParMaster @FacilityName,@LocationName,@ItemDescription" 
            UpdateCommand="exec sp_EditBlueBinParMaster @ParMasterID,@FacilityID,@ItemID,@LocationID,@BinSequence,@BinUOM,@BinQuantity,@LeadTime,@ItemType,@WHLocation,@WHSequence,@PatientCharge">


        <DeleteParameters>
            <asp:Parameter Name="ParMasterID" Type="Int32"></asp:Parameter>

        </DeleteParameters>
        <UpdateParameters>
            <asp:Parameter Name="ParMasterID" Type="Int32"></asp:Parameter>
            <asp:Parameter Name="FacilityID" Type="Int32"></asp:Parameter>
            <asp:Parameter Name="ItemID" Type="String"></asp:Parameter>
            <asp:Parameter Name="LocationID" Type="String"></asp:Parameter>
                        <asp:Parameter Name="BinSequence" Type="String"></asp:Parameter>
                        <asp:Parameter Name="BinUOM" Type="String"></asp:Parameter>
                        <asp:Parameter Name="BinQuantity" Type="Int32"></asp:Parameter>
                        <asp:Parameter Name="LeadTime" Type="Int32"></asp:Parameter>
                        <asp:Parameter Name="ItemType" Type="String"></asp:Parameter>
                        <asp:Parameter Name="WHLocationID" Type="String"></asp:Parameter>
                        <asp:Parameter Name="WHSequence" Type="String"></asp:Parameter>
                        <asp:Parameter Name="PatientCharge" Type="Int32"></asp:Parameter>

        </UpdateParameters>
            <SelectParameters>
                <asp:ControlParameter ControlID="FacilitySB" Name="FacilityName" PropertyName="Text" DefaultValue="%"  />
                <asp:ControlParameter ControlID="LocationSB" Name="LocationName" PropertyName="Text" DefaultValue="%"  />
                <asp:ControlParameter ControlID="ItemSB" Name="ItemDescription" PropertyName="Text" DefaultValue="%"  />
            </SelectParameters>
    </asp:SqlDataSource>

</p>

    <p>
        <asp:SqlDataSource runat="server" ID="ItemMasterDataSource" ConnectionString='<%$ ConnectionStrings:Site_ConnectionString %>' 
            DeleteCommand="exec sp_DeleteBlueBinItemMaster @ItemMasterID" 
            SelectCommand="exec sp_SelectBlueBinItemMaster @ItemDescription" 
            UpdateCommand="exec sp_EditBlueBinItemMaster @ItemMasterID,@ItemID,@ItemDescription,@ItemDescription2">
        <DeleteParameters>
            <asp:Parameter Name="ItemMasterID" Type="Int32"></asp:Parameter>
        </DeleteParameters>
        <UpdateParameters>
            <asp:Parameter Name="ItemMasterID" Type="Int32"></asp:Parameter>
            <asp:Parameter Name="ItemID" Type="String"></asp:Parameter>
            <asp:Parameter Name="ItemDescription" Type="String"></asp:Parameter>
            <asp:Parameter Name="ItemDescription2" Type="String"></asp:Parameter>
        </UpdateParameters>
            <SelectParameters>
                <asp:ControlParameter ControlID="ItemSB" Name="ItemDescription" PropertyName="Text" DefaultValue="%"  />
            </SelectParameters>
    </asp:SqlDataSource>

</p>

         <p>
        <asp:SqlDataSource runat="server" ID="LocationMasterDataSource" ConnectionString='<%$ ConnectionStrings:Site_ConnectionString %>' 
            DeleteCommand="exec sp_DeleteBlueBinLocationMaster @LocationMasterID" 
            SelectCommand="exec sp_SelectBlueBinLocationMaster @LocationName" 
            UpdateCommand="exec sp_EditBlueBinLocationMaster @LocationMasterID,@LocationID,@LocationName">
        <DeleteParameters>
            <asp:Parameter Name="LocationMasterID" Type="Int32"></asp:Parameter>
            <asp:Parameter Name="LocationID" Type="String"></asp:Parameter>
            <asp:Parameter Name="LocationName" Type="String"></asp:Parameter>
        </DeleteParameters>
        <UpdateParameters>
            <asp:Parameter Name="LocationMasterID" Type="Int32"></asp:Parameter>
            <asp:Parameter Name="LocationID" Type="String"></asp:Parameter>
            <asp:Parameter Name="LocationName" Type="String"></asp:Parameter>
        </UpdateParameters>
            <SelectParameters>
                <asp:ControlParameter ControlID="LocationSB" Name="LocationName" PropertyName="Text" DefaultValue="%"  />
            </SelectParameters>
    </asp:SqlDataSource>
<asp:SqlDataSource runat="server" ID="FacilityDataSource" ConnectionString='<%$ ConnectionStrings:Site_ConnectionString %>' SelectCommand="SELECT DISTINCT rtrim([FacilityID]) as FacilityID,[FacilityName] FROM bluebin.[BlueBinFacility]"></asp:SqlDataSource>
<asp:SqlDataSource runat="server" ID="LocationDataSource" ConnectionString='<%$ ConnectionStrings:Site_ConnectionString %>' SelectCommand="SELECT DISTINCT rtrim([LocationID]) as LocationID,rtrim([LocationName]) as LocationName FROM bluebin.[BlueBinLocationMaster]"></asp:SqlDataSource>
<asp:SqlDataSource runat="server" ID="ItemDataSource" ConnectionString='<%$ ConnectionStrings:Site_ConnectionString %>' SelectCommand="SELECT DISTINCT rtrim([ItemID]) as ItemID,[ItemDescription],rTrim(ItemID)+ ' - ' + COALESCE(ItemDescription,ItemDescription2,'No Description') as ExtendedDescription FROM bluebin.[BlueBinItemMaster]"></asp:SqlDataSource>
<asp:SqlDataSource runat="server" ID="BinUOMDataSource" ConnectionString='<%$ ConnectionStrings:Site_ConnectionString %>' SelectCommand="select distinct BinUOM from bluebin.BlueBinParMaster"></asp:SqlDataSource>

         </p>

   
     
</asp:Content>