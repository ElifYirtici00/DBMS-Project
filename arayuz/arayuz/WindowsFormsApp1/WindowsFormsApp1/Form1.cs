using Npgsql;
using System;
using System.Collections.Generic;
using System.ComponentModel;
using System.Data;
using System.Drawing;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using System.Windows.Forms;
using static System.Windows.Forms.VisualStyles.VisualStyleElement;

namespace WindowsFormsApp1
{
    public partial class Form1 : Form
    {
        public Form1()
        {
            InitializeComponent();  
        }

        private DataGridView dataGridView1;
        private System.Windows.Forms.Button btn_list;
        private System.Windows.Forms.Button btn_search;
        private System.Windows.Forms.Button btn_insert;
        private System.Windows.Forms.Button btn_update;
        private System.Windows.Forms.Button btn_delete;
        private Label lbl_countryId;
        private Label lbl_name;
        private System.Windows.Forms.TextBox txt_countryId;
        private System.Windows.Forms.TextBox txt_name;
        Npgsql.NpgsqlConnection connect = new Npgsql.NpgsqlConnection(
           System.IO.File.ReadAllText(
               System.IO.Path.Combine(
                   System.AppDomain.CurrentDomain.BaseDirectory,
                   "db.local.txt")).Trim());

        private void Form1_Load(object sender, EventArgs e)
        {

        }
        private void InitializeComponent()
        {
            this.dataGridView1 = new System.Windows.Forms.DataGridView();
            this.btn_list = new System.Windows.Forms.Button();
            this.btn_search = new System.Windows.Forms.Button();
            this.btn_insert = new System.Windows.Forms.Button();
            this.btn_update = new System.Windows.Forms.Button();
            this.btn_delete = new System.Windows.Forms.Button();
            this.lbl_countryId = new System.Windows.Forms.Label();
            this.lbl_name = new System.Windows.Forms.Label();
            this.txt_countryId = new System.Windows.Forms.TextBox();
            this.txt_name = new System.Windows.Forms.TextBox();
            ((System.ComponentModel.ISupportInitialize)(this.dataGridView1)).BeginInit();
            this.SuspendLayout();
            // 
            // dataGridView1
            // 
            this.dataGridView1.ColumnHeadersHeightSizeMode = System.Windows.Forms.DataGridViewColumnHeadersHeightSizeMode.AutoSize;
            this.dataGridView1.Location = new System.Drawing.Point(8, 16);
            this.dataGridView1.Name = "dataGridView1";
            this.dataGridView1.RowHeadersWidth = 51;
            this.dataGridView1.Size = new System.Drawing.Size(688, 477);
            this.dataGridView1.TabIndex = 0;
            // 
            // btn_list
            // 
            this.btn_list.Location = new System.Drawing.Point(722, 271);
            this.btn_list.Name = "btn_list";
            this.btn_list.Size = new System.Drawing.Size(83, 50);
            this.btn_list.TabIndex = 1;
            this.btn_list.Text = "LIST";
            this.btn_list.UseVisualStyleBackColor = true;
            this.btn_list.Click += new System.EventHandler(this.btn_list_Click_1);
            // 
            // btn_search
            // 
            this.btn_search.Location = new System.Drawing.Point(842, 271);
            this.btn_search.Name = "btn_search";
            this.btn_search.Size = new System.Drawing.Size(78, 50);
            this.btn_search.TabIndex = 2;
            this.btn_search.Text = "SEARCH";
            this.btn_search.UseVisualStyleBackColor = true;
            this.btn_search.Click += new System.EventHandler(this.btn_search_Click_1);
            // 
            // btn_insert
            // 
            this.btn_insert.Location = new System.Drawing.Point(722, 355);
            this.btn_insert.Name = "btn_insert";
            this.btn_insert.Size = new System.Drawing.Size(83, 48);
            this.btn_insert.TabIndex = 3;
            this.btn_insert.Text = "INSERT";
            this.btn_insert.UseVisualStyleBackColor = true;
            this.btn_insert.Click += new System.EventHandler(this.btn_insert_Click_1);
            // 
            // btn_update
            // 
            this.btn_update.Location = new System.Drawing.Point(842, 355);
            this.btn_update.Name = "btn_update";
            this.btn_update.Size = new System.Drawing.Size(78, 48);
            this.btn_update.TabIndex = 4;
            this.btn_update.Text = "UPDATE";
            this.btn_update.UseVisualStyleBackColor = true;
            this.btn_update.Click += new System.EventHandler(this.btn_update_Click_1);
            // 
            // btn_delete
            // 
            this.btn_delete.Location = new System.Drawing.Point(777, 423);
            this.btn_delete.Name = "btn_delete";
            this.btn_delete.Size = new System.Drawing.Size(94, 52);
            this.btn_delete.TabIndex = 5;
            this.btn_delete.Text = "DELETE";
            this.btn_delete.UseVisualStyleBackColor = true;
            this.btn_delete.Click += new System.EventHandler(this.btn_delete_Click_1);
            // 
            // lbl_countryId
            // 
            this.lbl_countryId.AutoSize = true;
            this.lbl_countryId.Location = new System.Drawing.Point(719, 47);
            this.lbl_countryId.Name = "lbl_countryId";
            this.lbl_countryId.Size = new System.Drawing.Size(64, 16);
            this.lbl_countryId.TabIndex = 6;
            this.lbl_countryId.Text = "countryId:";
            // 
            // lbl_name
            // 
            this.lbl_name.AutoSize = true;
            this.lbl_name.Location = new System.Drawing.Point(719, 92);
            this.lbl_name.Name = "lbl_name";
            this.lbl_name.Size = new System.Drawing.Size(44, 16);
            this.lbl_name.TabIndex = 7;
            this.lbl_name.Text = "name:";
            // 
            // txt_countryId
            // 
            this.txt_countryId.Location = new System.Drawing.Point(812, 41);
            this.txt_countryId.Name = "txt_countryId";
            this.txt_countryId.Size = new System.Drawing.Size(75, 22);
            this.txt_countryId.TabIndex = 8;
            // 
            // txt_name
            // 
            this.txt_name.Location = new System.Drawing.Point(812, 92);
            this.txt_name.Name = "txt_name";
            this.txt_name.Size = new System.Drawing.Size(75, 22);
            this.txt_name.TabIndex = 9;
            // 
            // Form1
            // 
            this.ClientSize = new System.Drawing.Size(1106, 515);
            this.Controls.Add(this.txt_name);
            this.Controls.Add(this.txt_countryId);
            this.Controls.Add(this.lbl_name);
            this.Controls.Add(this.lbl_countryId);
            this.Controls.Add(this.btn_delete);
            this.Controls.Add(this.btn_update);
            this.Controls.Add(this.btn_insert);
            this.Controls.Add(this.btn_search);
            this.Controls.Add(this.btn_list);
            this.Controls.Add(this.dataGridView1);
            this.Name = "Form1";
            ((System.ComponentModel.ISupportInitialize)(this.dataGridView1)).EndInit();
            this.ResumeLayout(false);
            this.PerformLayout();

        }

        private void btn_list_Click_1(object sender, EventArgs e)
        {      
            string query = "select * from \"Country\"";
            NpgsqlDataAdapter adapt = new NpgsqlDataAdapter(query, connect);
            DataSet ds = new DataSet();
            adapt.Fill(ds);
            //connect.Close();
            dataGridView1.DataSource = ds.Tables[0];        
    }

        private void btn_search_Click_1(object sender, EventArgs e)
        {
            connect.Open();

            NpgsqlCommand commandGetByID = new NpgsqlCommand("select * from \"Country\" where \"countryId\"=@countryId", connect);

            commandGetByID.Parameters.AddWithValue("@countryId", (txt_countryId.Text));

            NpgsqlDataAdapter adapt = new NpgsqlDataAdapter(commandGetByID);
            DataSet ds = new DataSet();
            adapt.Fill(ds);

            dataGridView1.DataSource = ds.Tables[0];

            connect.Close();
        }

        private void btn_insert_Click_1(object sender, EventArgs e)
        {
            connect.Open();
            NpgsqlCommand command1 = new NpgsqlCommand("insert into \"Country\" values(@countryId, @name)", connect);
            command1.Parameters.AddWithValue("@countryId", (txt_countryId.Text));
            command1.Parameters.AddWithValue("@name", txt_name.Text);
            command1.ExecuteNonQuery();
            connect.Close();
            MessageBox.Show("Country insert operation has been done successfully.");
        }

        private void btn_update_Click_1(object sender, EventArgs e)
        {
            connect.Open();

            NpgsqlCommand commandUpdate = new NpgsqlCommand("update \"Country\" set name=@name where \"countryId\"=@countryId", connect);

            commandUpdate.Parameters.AddWithValue("@countryId", (txt_countryId.Text));
            commandUpdate.Parameters.AddWithValue("@name", (txt_name.Text));
            commandUpdate.ExecuteNonQuery();
            connect.Close();

            MessageBox.Show("Country update operation has been done successfully.");
        }

        private void btn_delete_Click_1(object sender, EventArgs e)
        {
            connect.Open();

            NpgsqlCommand commandDelete = new NpgsqlCommand("delete from \"Country\" where \"countryId\"=@countryId", connect);

            commandDelete.Parameters.AddWithValue("@countryId", (txt_countryId.Text));

            commandDelete.ExecuteNonQuery();
            connect.Close();

            MessageBox.Show("Country delete operation has been done successfully.");
        }
    }
}
